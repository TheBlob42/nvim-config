-- BUFDELETE

vim.keymap.set('n', '<leader>bd', '<CMD>Bdelete<CR>', { desc = 'delete buffer' })
vim.keymap.set('n', '<leader>bD', '<CMD>Bdelete!<CR>', { desc = 'force delete buffer' })

-- EASY ALIGN

vim.keymap.set('x', 'ga', '<Plug>(EasyAlign)', { desc = 'easy align' })
vim.keymap.set('n', 'ga', '<Plug>(EasyAlign)', { desc = 'easy align' })

-- FLOATERM

-- configuration for the floating terminal window
vim.g.floaterm_width      = 0.75
vim.g.floaterm_height     = 0.75
vim.g.floaterm_autoinsert = false

vim.keymap.set('n', "<leader>'", '<CMD>FloatermToggle<CR>', { desc = 'toggle terminal' })

-- SUDA.VIM

vim.keymap.set('n', '<leader>fer', '<CMD>SudaRead<CR>', { desc = 'sudo read' })
vim.keymap.set('n', '<leader>few', '<CMD>SudaWrite<CR>', { desc = 'sudo write' })

-- UNDOTREE

vim.g.undotree_WindowLayout = 4
vim.g.undotree_SetFocusWhenToggle = 1

vim.keymap.set('n', '<leader>U', '<CMD>UndotreeToggle<CR>', { desc = 'undo tree' })
