local wk = require('which-key')

---@diagnostic disable-next-line: missing-fields
wk.setup {
    plugins = {
        marks = false,
        registers = false,
        spelling = { enabled = true },
        presets = {
            operators = false, -- not useful due to `vim-cutlass`
            motions = false,
            text_objects = false,
            windows = false,
            nav = false,
            g = true,
            z = true,
        }
    },
    defer = function(ctx)
        -- don't trigger when switching to visual mode
        return ctx.mode == 'v' or ctx.mode == 'V' or ctx.mode == '<C-v>'
    end,
    icons = {
        rules = false
    }
}

wk.add({
    { '<leader>', group = 'Main-Menu' },
    { '<leader>b', group = 'Buffers' },
    { '<leader>c', group = 'Spelling' },
    { '<leader>e', group = 'Errors' },
    { '<leader>f', group = 'Files'},
    { '<leader>fe', group = 'Sudo Edit' },
    { '<leader>i', group = 'Insert' },
    { '<leader>p', group = 'Project' },
    { '<leader>q', group = 'Quit' },
    { '<leader>s', group = 'Search' },
    { '<leader>t', group = 'Tabs' },
    { '<leader>w', group = 'Windows' },
    {
        mode = { 'v' },
        { '<leader>c', group = 'Multi Cursor' },
    },
    {
        mode = { 'n', 'v' },
        { '<leader>g', group = 'Git' },
        { '<localleader>', group = function()
            local ft = vim.opt.filetype:get()
            return string.upper(ft:sub(1, 1)) .. ft:sub(2)
        end },
    }
})
