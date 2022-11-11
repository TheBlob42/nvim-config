-- copy before commenting via 'gy'
local opts = { remap = true, desc = 'copy then comment' }

vim.keymap.set('x', 'gy', 'ygvgc', opts)
vim.keymap.set('n', 'gyy', 'yygcc', opts)
vim.keymap.set('n', 'gy', ':set opfunc=Comment<CR>g@', opts)

vim.cmd [[
    function! Comment(type)
        silent exec 'normal! `[V`]y'
        " no '!' (normal!) so that 'gc' works properly
        silent exec 'normal `[V`]gc'
    endfunction
]]
