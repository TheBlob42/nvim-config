--[[
    Show LSP document symbol breadcrumbs in the `winbar` for better orientation

    - Only works for with an active language server (setup on `LspAttach`)
    - Filetypes can be specified in custom configuration options
    - Data update only initially and when the buffer text changes

    You have to call the `setup` function to enable the functionality
--]]
local M = {}

local breadcrumbs_augroup = vim.api.nvim_create_augroup("LSPBreadcrumbs", { clear = true })

---@class BreadcrumbOptions
---@field filetypes string[] The filetypes for which breadcrumbs should be activated (only if a language server is available). An empty list means its activated for ALL filetypes
local options = {
    filetypes = {}
}

---Custom highlights and icons for the different document symbol kinds
---https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind
---@type table<integer, string[]>
local symbol_kinds = {
    [1]  = { '@module', '󰈙' }, -- file
    [2]  = { '@module', '' }, -- module
    [3]  = { '@lsp.type.namespace', '󰌗' }, -- namespace
    [4]  = { '@lsp.type.namespace', '' }, -- package
    [5]  = { '@lsp.type.class', '󰌗' }, -- class
    [6]  = { '@lsp.type.method', '󰆧' }, -- method
    [7]  = { '@lsp.type.property', '' }, -- property
    [8]  = { '@lsp.type.property', '' }, -- field
    [9]  = { '@constructor', '' }, -- constructor
    [10] = { '@lsp.type.enum', '󰕘' }, -- enum
    [11] = { '@lsp.type.interface', '󰕘' }, -- interface
    [12] = { '@lsp.type.function', '󰊕' }, -- function
    [13] = { '@lsp.type.variable', '󰆧' }, -- variable
    [14] = { '@constant', '󰏿' }, -- constant
    [15] = { '@lsp.type.string', '󰀬' }, -- string
    [16] = { '@number', '󰎠' }, -- number
    [17] = { '@lsp.type.boolean', '◩' }, -- boolean
    [18] = { '@lsp.type.struct', '󰅪' }, -- array
    [19] = { '@lsp.type.struct', '󰅩' }, -- object
    [20] = { '@lsp.type.keyword', '󰌋' }, -- key
    [21] = { '@constant', '󰟢' }, -- null
    [22] = { '@lsp.type.enumMember', '' }, -- enumMember
    [23] = { '@lsp.type.struct', '󰌗' }, -- struct
    [24] = { '@lsp.type.event', '' }, -- event
    [25] = { '@lsp.type.operator', '󰆕' }, -- operator
    [26] = { '@lsp.type.typeParameter', '󰊄' }, -- typeParameter
}

---Names of clients that should not be requested, usually reserved for more general, utility or AI related servers
---@type string[]
local clients_to_ignore = {
    'GitHub Copilot',
    'kulala'
}

---Return the symbol path for the `cursor` position in `buf`
---@param buf integer The current buffer
---@param symbols lsp.DocumentSymbol[] The LSP symbols for `buf`
---@param cursor vim.Range The cursor position
---@return string[]? path The path of symbols to the cursor position
local function symbol_path(buf, symbols, cursor)
    for _, symbol in ipairs(symbols) do
        -- when text is deleted there can be a "race condition" where the symbols are not updated fast enough,
        -- so that creating an LSP range fails if the symbol still refers to parts of the buffer that don't exist anymore
        -- therefore we use `pcall` to catch these issues
        local ok, symbol_range = pcall(vim.range.lsp, buf, symbol.range, 'utf-16')
        if ok and symbol_range:has(cursor) then
            local path = {}
            if symbol.children then
                path = symbol_path(buf, symbol.children, cursor) or {}
            end
            -- table.insert(path, 1, symbol.name)
            local hl, icon = unpack(symbol_kinds[symbol.kind])
            table.insert(path, 1, '%#'..hl..'#'..icon..' '..symbol.name..'%*')
            return path
        end
    end
end

---Holds the document symbol data per buffer (client --> symbols)
---@type table<integer, table<integer, lsp.DocumentSymbol[]>>
local symbol_data = {}

---Fetch the symbol paths for all supported clients
---@param data table<integer, lsp.DocumentSymbol[]> Symbol data to check
---@return table<integer, string[]> paths
local function get_all_symbol_paths(data)
    local buf = vim.api.nvim_get_current_buf()
    local cursor = vim.pos.cursor(vim.api.nvim_win_get_cursor(0))
    local cursor_range = vim.range(cursor, cursor)
    local paths = {}

    for client_id, symbols in pairs(data) do
        local path = symbol_path(buf, symbols, cursor_range)
        if path then
            paths[client_id] = path
        end
    end

    return paths
end

---Set the symbol path for the given `buf`
---Uses the `winbar` option for this
---If there is no symbol path for whatever reason, the `winbar` option is cleared
---@param buf integer The buffer id
local function set_symbol_path(buf)
    local res = {}
    for _, path in pairs(get_all_symbol_paths(symbol_data[buf] or {})) do
        if not vim.tbl_isempty(path) then
            table.insert(res, table.concat(path, ' > '))
        end
    end

    if not vim.tbl_isempty(res) then
        vim.wo.winbar = table.concat(res, ' | ')
    else
        vim.wo.winbar = ' Root' -- add something so the winbar doesn't flicker
    end
end

---Update the LSP document symbols for the given `buf`
---@param buf integer The buffer id
local function get_lsp_symbols(buf)
    local clients = vim.lsp.get_clients({
        bufnr = buf,
        method = 'textDocument/documentSymbol',
    })
    if vim.tbl_isempty(clients) then
        return
    end

    local uri = vim.lsp.util.make_text_document_params(buf)['uri']
    if not uri then
        return
    end

    local params = {
        textDocument = {
            uri = uri
        }
    }

    for _, client in ipairs(clients) do
        if vim.tbl_contains(clients_to_ignore, client.name) then
            -- do nothing
        else
            client:request('textDocument/documentSymbol', params, function(error, data)
                if error or not data or vim.tbl_isempty(data) then
                    return
                end

                if not symbol_data[buf] then
                    symbol_data[buf] = {}
                end
                symbol_data[buf][client.id] = data

                set_symbol_path(buf)
            end)
        end
    end
end

---Setup breadcrumbs
---@param opts? BreadcrumbOptions
function M.setup(opts)
    options = vim.tbl_extend('force', options, opts or {})

    vim.api.nvim_create_autocmd('LspAttach', {
        group = breadcrumbs_augroup,
        pattern = '*',
        callback = function(ev)
            local ft = options.filetypes
            if not vim.tbl_isempty(ft) and not vim.tbl_contains(ft, vim.bo[ev.buf].filetype) then
                return
            end

            -- initial retrieval of all LSP document symbols
            get_lsp_symbols(ev.buf)
            -- only update the symbol cache when the buffer text changes
            vim.api.nvim_buf_attach(ev.buf, false, {
                on_lines = function()
                    get_lsp_symbols(ev.buf)
                end,
            })

            -- check for current symbol path on each cursor movement
            vim.api.nvim_create_autocmd('CursorMoved', {
                group = breadcrumbs_augroup,
                buffer = ev.buf,
                desc = 'Update breadcrumbs on cursor movement',
                callback = function()
                    set_symbol_path(ev.buf)
                end,
            })
        end,
        desc = 'Setup breadcrumb configuration',
    })
end

return M
