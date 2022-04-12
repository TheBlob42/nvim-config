vim.g.undotree_WindowLayout = 4
vim.g.undotree_SetFocusWhenToggle = 1

vim.keymap.set('n', '<leader>U', '<CMD>UndotreeToggle<CR>', { desc = 'undo tree' })
