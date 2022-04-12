-- disable by default
vim.g.gitblame_enabled = 0

vim.keymap.set('n', '<leader>gb', '<CMD>GitBlameToggle<CR>', { desc = 'git blame' })
