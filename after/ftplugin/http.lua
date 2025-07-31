local kulala = require('kulala')

-- check this documentation page for available kulala keymaps:
-- https://neovim.getkulala.net/docs/getting-started/default-keymaps

vim.keymap.set({ 'n', 'x' }, '<localleader>s', kulala.run, { buffer = true, desc = 'Send request' })
vim.keymap.set('n', '<localleader>o', kulala.open, { buffer = true, desc = 'Open info buffer' })
vim.keymap.set('n', '<localleader>C', require('kulala.ui').interrupt_requests, { buffer = true, desc = 'Cancel requests' })

require('which-key').add {{ '<localleader>c', group = 'cULR', buffer = true }}
vim.keymap.set('n', '<localleader>cc', kulala.copy, { buffer = true, desc = 'Copy as cURL' })
vim.keymap.set('n', '<localleader>cp', kulala.from_curl, { buffer = true, desc = 'Paste from cURL' })

-- use improved LSP symbol search to search for available requests in buffer
vim.keymap.set('n', 'gO', require('user.plugins.lsp-symbols').lsp_symbols, { buffer = true, desc = 'Search requests' })

-- enable manual folding via `foldmarker`
vim.opt_local.foldmethod = 'marker'
--- the default vim markers `{{{,}}}` are shown as errors by kulala language server
vim.opt_local.foldmarker = '|||,$$$'
-- close folds by default for better overview
vim.opt_local.foldlevel = 0
