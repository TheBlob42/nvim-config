local status_ok, lualine = my.req('lualine')
if not status_ok then
    return
end

-- custom extension for DREX
local function short_path()
    local path = require('drex.utils').get_root_path(0)
    return vim.fn.fnamemodify(path, ':~')
end

local function clipboard_entries()
    return vim.tbl_count(require('drex.actions').clipboard)
end

local drex_extension = {
    sections = {
        lualine_a = { 'winnr' },
        lualine_b = { short_path },
        lualine_z = { clipboard_entries }
    },
    filetypes = { 'drex' },
}

lualine.setup {
    options = {
        theme = 'auto',
    },
    extensions = { drex_extension },
    sections = {
        lualine_a = { 'winnr' },
        lualine_b = { 'branch' },
        lualine_c = { 'filename' },
        lualine_x = {
            { "diagnostics", sources = { "nvim_diagnostic" } },
            'filetype',
        },
    },
    inactive_sections = {
        lualine_a = { 'winnr' }
    },
}
