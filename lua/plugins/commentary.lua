-- copy before commenting via 'gy'
vim.keymap.set('n', 'gyy', 'yygcc', { remap = true })
vim.keymap.set('n', 'gy', ':set opfunc=Comment<CR>g@', { remap = true })
vim.cmd [[
    function! Comment(type)
        silent exec 'normal! `[V`]y'
        " no '!' (normal!) so that 'gc' works properly
        silent exec 'normal `[V`]gc'
    endfunction
]]
vim.keymap.set('x', 'gy', 'ygvgc', { remap = true })
