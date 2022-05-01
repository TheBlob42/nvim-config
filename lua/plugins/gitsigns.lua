local status_ok, gitsigns = my.req('gitsigns')
if not status_ok then
    return
end

-- make jumps repeatable (with `vim-repeat`)
local repeat_map = my.repeat_map
repeat_map('<Plug>GitSignsNextHunk', '<CMD>lua require("gitsigns").next_hunk()<CR>')
repeat_map('<Plug>GitSignsPrevHunk', '<CMD>lua require("gitsigns").prev_hunk()<CR>')

gitsigns.setup {
    keymaps = {}, -- NO default keybindings
}

vim.keymap.set('n', '<leader>gp', require("gitsigns").preview_hunk, { desc = 'preview git hunk' })
vim.keymap.set('n', '<leader>gn', '<Plug>GitSignsNextHunk', { desc = 'next git hunk' })
vim.keymap.set('n', '<leader>gN', '<Plug>GitSignsPrevHunk', { desc = 'previous git hunk' })
vim.keymap.set('n', '<leader>gs', require("gitsigns").stage_hunk, { desc = 'stage git hunk' })
vim.keymap.set('n', '<leader>gr', require("gitsigns").reset_hunk, { desc = 'reset git hunk' })
