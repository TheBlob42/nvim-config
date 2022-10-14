local gitsigns = require('gitsigns')

gitsigns.setup {
    keymaps = {}, -- NO default keybindings
}

-- make jumps repeatable (with `vim-repeat`)
local repeat_map = my.repeat_map
repeat_map('<Plug>GitSignsNextHunk', '<CMD>lua require("gitsigns").next_hunk()<CR>')
repeat_map('<Plug>GitSignsPrevHunk', '<CMD>lua require("gitsigns").prev_hunk()<CR>')

vim.keymap.set('n', '<leader>gp', gitsigns.preview_hunk, { desc = 'preview git hunk' })
vim.keymap.set('n', '<leader>gn', '<Plug>GitSignsNextHunk', { desc = 'next git hunk' })
vim.keymap.set('n', '<leader>gN', '<Plug>GitSignsPrevHunk', { desc = 'previous git hunk' })
vim.keymap.set('n', '<leader>gs', gitsigns.stage_hunk, { desc = 'stage git hunk' })
vim.keymap.set('n', '<leader>gr', gitsigns.reset_hunk, { desc = 'reset git hunk' })
