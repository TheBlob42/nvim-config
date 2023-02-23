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
    window = {
        border = 'single',
    },
}

wk.register({
    name = 'Main-Menu',
    ['b'] = { name = 'Buffers' },
    ['c'] = { name = 'Spelling' },
    ['e'] = { name = 'Errors' },
    ['f'] = {
        name = 'Files',
        ['e'] = { name = 'Sudo Edit' }
    },
    ['g'] = { name = 'Git' },
    ['i'] = { name = 'Insert' },
    ['p'] = { name = 'Project' },
    ['q'] = { name = 'Quit' },
    ['s'] = { name = 'Search' },
    ['t'] = { name = 'Tabs' },
    ['w'] = { name = 'Windows' },
}, {
    prefix = '<leader>'
})

wk.register({
    name = 'Main-Menu',
    [''] =  { function() wk.show(vim.g.mapleader, { mode = 'v' }) end, ''},
    ['c'] = { name = 'Multi Cursor' },
    ['g'] = { name = 'Git'},
}, {
    prefix = '<leader>',
    mode = 'v'
})

wk.register({
    name = 'Local',
}, {
    prefix = vim.g.maplocalleader,
    mode = { 'n', 'v' }
})
