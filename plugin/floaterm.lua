-- configuration for the floating terminal window
vim.g.floaterm_width      = 0.75
vim.g.floaterm_height     = 0.75
vim.g.floaterm_autoinsert = false

vim.keymap.set('n', "<leader>'", '<CMD>FloatermToggle<CR>', { desc = 'toggle terminal' })
