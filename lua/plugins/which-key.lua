local wk = require('which-key')

wk.setup {
    -- disable ALL builtin plugins
    plugins = {
        marks = false,
        registers = false,
        spelling = { enabled = false },
        presets = {
            operators = false, -- not useful due to `vim-cutlass`
            motions = false,
            text_objects = false,
            windows = false,
            nav = false,
            g = false,
            z = false,
        }
    },
}

wk.register({
    name = 'Main-Menu',
    -- there should be only one entry for window jumping in which-key
    ['<1-9>'] = 'goto window 1-9',
    ['1'] = 'which_key_ignore',
    ['2'] = 'which_key_ignore',
    ['3'] = 'which_key_ignore',
    ['4'] = 'which_key_ignore',
    ['5'] = 'which_key_ignore',
    ['6'] = 'which_key_ignore',
    ['7'] = 'which_key_ignore',
    ['8'] = 'which_key_ignore',
    ['9'] = 'which_key_ignore',
    ['b'] = { name = '+Buffers' },
    ['e'] = { name = '+Errors' },
    ['f'] = {
        name = '+Files',
        ['e'] = { name = '+Sudo Edit' }
    },
    ['g'] = { name = '+Git' },
    ['i'] = { name = '+Insert' },
    ['p'] = { name = '+Project' },
    ['q'] = { name = '+Quit' },
    ['s'] = { name = '+Search' },
    ['t'] = { name = '+Tabs' },
    ['w'] = { name = '+Windows' },
}, { prefix = '<leader>' })

wk.register({
    name = 'Local',
}, { prefix = vim.g.maplocalleader })

vim.keymap.set('v', '<leader>', function()
    wk.show(vim.g.mapleader, { mode = 'v' })
end)
