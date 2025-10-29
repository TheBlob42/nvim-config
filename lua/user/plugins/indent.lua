--[[
    Simple module to automatically detect the correct values for:
    - tabstop
    - shiftwidth
    - softtabstop

    Will only check a configurable maximum number of lines per file to avoid slowdown (default: 10000)
    Ignores comments using treesitter (only for the current buffer and only if possible)
    Only checks for "expected" indentations (by default: 2, 4 or 8)
    Checks other files with the same file extension in the current and parent directories if nothing is found
--]]
local M = {}

---@class IndentationOptions
---@field max_lines integer Maximum number of lines to check per file
---@field max_parents integer Maximum number of parent directories to check for other files
---@field permitted_indentations integer[] Indentation values that we are looking for
local default_options = {
    max_lines = 10000,
    max_parents = 20,
    permitted_indentations = { 2, 4, 8 },
}

local options = default_options

---Check if the position (`line` + `col`) in the given `buf` is inside a comment node
---@param buf integer The buffer id
---@param line integer The line number (0-indexed)
---@param col integer The column number (0-indexed)
---@return boolean is_comment
local function is_comment(buf, line, col)
    local ts = pcall(vim.treesitter.get_parser, buf)
    if not ts then
        return false
    end

    local node = vim.treesitter.get_node({
        bufnr = buf,
        pos = { line, col },
    })
    if not node then
        return false
    end

    return node:type():lower():match('comment')
end

---Check the indentation for the given `lines`
---@param lines string[] The lines to check for indentation values
---@param buf integer? Optional buffer identifier for checking for comments
---@return integer? indentation
local function check_indentation(lines, buf)
    buf = buf or -1
    for index, line in ipairs(lines) do
        local indent = line:match('^([ ]+)') -- only check spaces NOT tabs
        if indent and vim.tbl_contains(options.permitted_indentations, #indent) then
            if buf > 0 and is_comment(buf, index - 1, #indent) then
                -- skip this comment line
            else
                return #indent
            end
        end
    end
end

---Check the indentation for the given `buf`
---@param buf integer The buffer id
---@return integer? indentation
local function check_buf_indentation(buf)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, options.max_lines, false)
    return check_indentation(lines, buf)
end

---Set the indentation for the given `buf`
---@param buf integer The buffer id
local function set_indentation(buf)
    -- if "indent_size" is already set via the .editorconfig plugin we skip our custom logic
    local editorconfig = vim.b[buf].editorconfig
    if editorconfig and editorconfig.indent_size then
        return
    end

    local buf_name = vim.api.nvim_buf_get_name(buf)
    local buf_path = vim.fn.fnamemodify(buf_name, ':p:h')
    local buf_ext = vim.fn.fnamemodify(buf_name, ':e')

    local detected = check_buf_indentation(buf)

    -- check directory for other files with the same extension for indentation 
    if not detected and buf_path ~= '' and buf_ext ~= '' and vim.uv.fs_stat(buf_path) then
        local counter = 1

        for path in vim.fs.parents(buf_name) do
            if counter > options.max_parents then
                break
            end
            counter = counter + 1

            for name, type in vim.fs.dir(path, {}) do
                if type == 'file' and vim.fn.fnamemodify(name, ':e') == buf_ext then
                    local file = vim.fs.joinpath(path, name)
                    -- read file content this way to avoid opening additional buffers and triggering autocommands
                    -- if the buffer is already loaded we can also check to avoid comments, but only then
                    -- this can make the algorithm not deterministic depending on which files you have loaded already
                    detected = check_indentation(vim.fn.readfile(file), vim.fn.bufnr(file))
                    if detected then
                        goto found
                    end
                end
            end
        end
    end

    ::found::

    if not detected then
        vim.bo[buf].expandtab = false
    else
        vim.bo[buf].expandtab = true
        vim.bo[buf].shiftwidth = detected
        vim.bo[buf].tabstop = detected
        vim.bo[buf].softtabstop = detected
    end
end

local group = vim.api.nvim_create_augroup('CustomIndent', {})

---Setup the indentation plugin
---@param opts IndentationOptions?
function M.setup(opts)
    options = vim.tbl_extend('force', default_options, opts or {})

    vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile', 'BufFilePost' }, {
        group = group,
        pattern = '*',
        callback = function(ev)
            -- to give the treesitter parser some time to parse
            vim.schedule(function()
                set_indentation(ev.buf)
            end)
        end,
    })
end

return M
