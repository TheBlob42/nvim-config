-- place for personal utility & configuration options
_G.my = {}

-- define leader keys as early as possible
vim.g.mapleader = ' '
vim.g.maplocalleader = ' m'

require('user.utils')        -- configuration utility
pcall(require, 'user.local') -- local user config (if present)

-- must be loaded before any other lua plugin
local status_ok, impatient = my.req('impatient')
if status_ok then
    impatient.enable_profile()
end
require('packer_compiled')

require('user.settings')
require('user.keymaps')
require('user.commands')
require('user.plugins')
require('lsp')
