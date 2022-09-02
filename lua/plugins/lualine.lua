local status_ok, lualine = my.req('lualine')
if not status_ok then
    return
end

lualine.setup {
    options = {
        theme = 'catppuccin',
    },
    extensions = { 'drex' },
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
