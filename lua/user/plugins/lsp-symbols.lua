--[[
    Replacement for the `lsp_symbols` function of the Snacks.picker (still requires snacks.nvim)
    This will include the symbol "path" in the picker so that one can easily filter by that as well
    In deeply nested files (e.g. big JSON configurations) this makes it easier to find exactly what you want

    There is no `setup` function as the setup has to be done manually during the LSP attachment
    If you want to adopt the default symbols or for a specific file type adopt the `filters` variable directly
--]]

local M = {}

-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind
local symbol_kinds = {
    [1] = 'File',
    [2] = 'Module',
    [3] = 'Namespace',
    [4] = 'Package',
    [5] = 'Class',
    [6] = 'Method',
    [7] = 'Property',
    [8] = 'Field',
    [9] = 'Constructor',
    [10] = 'Enum',
    [11] = 'Interface',
    [12] = 'Function',
    [13] = 'Variable',
    [14] = 'Constant',
    [15] = 'String',
    [16] = 'Number',
    [17] = 'Boolean',
    [18] = 'Array',
    [19] = 'Object',
    [20] = 'Key',
    [21] = 'Null',
    [22] = 'EnumMember',
    [23] = 'Struct',
    [24] = 'Event',
    [25] = 'Operator',
    [26] = 'TypeParameter',
}

---Use this to include all symbols in the output
local all_filters = vim.tbl_values(symbol_kinds)

---"Inspired" from snacks.nvim
local default_filters = {
    "Class",
    "Constructor",
    "Enum",
    "Field",
    "Function",
    "Interface",
    "Method",
    "Module",
    "Namespace",
    "Package",
    "Property",
    "Struct",
    "Trait",
}

local filters = {
    markdown = all_filters,
    help = all_filters,
    lua = {
        "Class",
        "Constructor",
        "Enum",
        "Field",
        "Function",
        "Interface",
        "Method",
        "Module",
        "Namespace",
        -- "Package", -- remove package since luals uses it for control flow structures
        "Property",
        "Struct",
        "Trait",
        "Object",
        "Array",
    },
    json = {
        "Module",
        "String",
        "Array",
        "Boolean",
        "Number"
    },
}

local function is(kind, symbol)
    return symbol_kinds[symbol.kind] == kind
end

function M.lsp_symbols()
    local buf = vim.api.nvim_get_current_buf()
    local ft = vim.bo.filetype
    local clients = vim.iter(vim.lsp.get_clients { bufnr = buf })
        :filter(function(c)
            return c.server_capabilities.documentSymbolProvider
        end)
        :totable()

    if vim.tbl_isempty(clients) then
        return
    end

    local filter = filters[ft] or default_filters
    local text_doc_params = vim.lsp.util.make_text_document_params(buf)

    local parsed = {}
    local parse
    parse = function(symbols, prefix)
        prefix = prefix or ''
        for _, sym in ipairs(symbols) do
            if sym.name and vim.tbl_contains(filter, symbol_kinds[sym.kind]) then
                table.insert(parsed, {
                    prefix = prefix,
                    name = sym.name,
                    kind = symbol_kinds[sym.kind],
                    text = symbol_kinds[sym.kind] .. prefix .. sym.name,
                    pos = { sym.range.start.line + 1, sym.range.start.character },
                    buf = buf,
                })

                if sym.children and not (is('Array', sym) or is('Object', sym)) then
                    parse(sym.children, prefix .. sym.name .. ' ⇒ ')
                end
            end
        end
    end

    for _, client in ipairs(clients) do
        local res, err = client:request_sync('textDocument/documentSymbol', { textDocument = text_doc_params }, 3000)
        if err then
            vim.notify('Something went wrong when requesting LSP symbols:\n'..err, vim.log.levels.ERROR, {})
        end
        if res then
            if res.err then
                vim.notify('Something went wrong when requesting LSP symbols:\n'..res.err.message, vim.log.levels.ERROR, {})
            end
            if res.result then
                parse(res.result)
            end
        end
    end

    local icons = require('snacks.picker.config.defaults').defaults.icons.kinds
    local longest = vim.iter(parsed)
        :map(function(e)
            return #(e.kind)
        end)
        :fold(0, function(init, l)
            return math.max(init, l)
        end)
    Snacks.picker {
        items = parsed,
        format = function(item)
            return {
                { icons[item.kind], 'SnacksPickerIcon' },
                { ('%-'..longest..'s'):format(item.kind), 'SnacksPickerIcon' },
                { ' | ', 'SnacksPickerFile' },
                { item.prefix, 'SnacksPickerComment' },
                { item.name, 'SnacksPickerFile' },
            }
        end,
        title = 'Lsp Symbols',
    }
end

return M
