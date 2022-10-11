local status_ok, wk = my.req('which-key')
if not status_ok then
    return
end

-- hinder `which-key` to mess with `telescope` when pasting in insert mode
vim.cmd('autocmd FileType TelescopePrompt inoremap <buffer> <silent> <C-r> <C-r>')

wk.setup {
    plugins = {
        spelling = { enabled = true },
        presets = {
            operators = false, -- not useful due to `vim-cutlass`
        }
    },
    triggers_blacklist = {
        -- since I'm using 'fd' as escape sequence mostly
        i = { 'f' },
        v = { 'f' },
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
