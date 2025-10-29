-- journal
local journal = require('user.plugins.journal')
journal.setup {}
vim.keymap.set('n', '<leader>J', journal.open, { desc = "Open this weeks journal entry" })

-- clever-f
require('user.plugins.clever-f').setup()

-- rooter
require('user.plugins.rooter').setup()

-- tabline
local tabline = require('user.plugins.tabline')
tabline.setup()
vim.keymap.set('n', '<leader>tt', tabline.switch_tab, { desc = 'Switch to another tab' })
vim.keymap.set('n', '<leader>tr', tabline.rename_tab, { desc = 'Rename the current tab' })

-- statusline
require('user.plugins.statusline').setup()

-- folds
require('user.plugins.folds').setup()

-- indentation
require('user.plugins.indent').setup()

-- snippets
require('user.plugins.snippets')
require('user.plugins.snippets.generic')
require('user.plugins.snippets.markdown')
require('user.plugins.snippets.javascript')
require('user.plugins.snippets.lua')
require('user.plugins.snippets.sh')
require('user.plugins.snippets.java')
