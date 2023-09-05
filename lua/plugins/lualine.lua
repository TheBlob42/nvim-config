require('lualine').setup {
    options = {
        theme = 'catppuccin',
    },
    extensions = { 'drex' },
    sections = {
        lualine_a = { 'winnr' },
        lualine_b = { 'branch' },
        lualine_c = {
            'filename',
            {
                function()
                    return '🔍'
                end,
                cond = function()
                    return vim.opt.spell:get() -- show spell checking indicator
                end,
            }
        },
        lualine_x = {
            { "diagnostics", sources = { "nvim_diagnostic" } },
            'filetype',
        },
    },
    inactive_sections = {
        lualine_a = { 'winnr' }
    },
}
