local gitsigns = require('gitsigns')

gitsigns.setup {
     signs = {
         add = { text = "┃" },
         change = { text = "┃" },
         delete = { text = "▶" },
         topdelete = { text = "▶" },
         changedelete = { text = "┃" },
         untracked = { text = "┃" },
     },
     signs_staged = {
         add = { text = "│" },
         change = { text = "│" },
         delete = { text = "▷" },
         topdelete = { text = "▷" },
         changedelete = { text = "│" },
     },
}

-- make jumps repeatable (with `vim-repeat`)
my.repeat_map('<Plug>GitSignsNextHunk', '<CMD>lua require("gitsigns").next_hunk()<CR>')
my.repeat_map('<Plug>GitSignsPrevHunk', '<CMD>lua require("gitsigns").prev_hunk()<CR>')

vim.keymap.set('n', '<leader>gp', gitsigns.preview_hunk, { desc = 'preview git hunk' })
vim.keymap.set('n', '<leader>gn', '<Plug>GitSignsNextHunk', { desc = 'next git hunk' })
vim.keymap.set('n', '<leader>gN', '<Plug>GitSignsPrevHunk', { desc = 'previous git hunk' })
vim.keymap.set('n', '<leader>gs', gitsigns.stage_hunk, { desc = 'stage git hunk' })
vim.keymap.set('n', '<leader>gr', gitsigns.reset_hunk, { desc = 'reset git hunk' })
vim.keymap.set('n', '<leader>gb', '<CMD>Gitsigns blame<CR>', { desc = 'git blame' })
