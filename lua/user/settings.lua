local opt = vim.opt
local g   = vim.g

-- define leader keys as early as possible
g.mapleader = ' '
g.maplocalleader = ' m'

opt.mouse = 'a'

opt.splitbelow = true
opt.splitright = true

opt.number = true
opt.signcolumn = 'number'

-- sync with system clipboard
opt.clipboard = { 'unnamed', 'unnamedplus' }

-- `vim-sleuth` might overwrite these
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true

opt.confirm = true

opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

opt.listchars = {
    eol = '⮯',
    tab = '<.>',
    trail = '~',
    extends = '➦',
    precedes = '⮪',
    space = '·',
}

opt.completeopt = { 'menuone', 'noselect' }

opt.timeoutlen = 500 -- for `which-key`
opt.updatetime = 400 -- speed up 'cursorhold' events

g.markdown_folding = 1 -- see 'ft-markdown-plugin'

-- opt in the new lua filetype detection
-- https://github.com/neovim/neovim/pull/16600
g.do_filetype_lua = 1
g.did_load_filetypes = 0

-- enable cursorline (except for terminal buffers)
opt.cursorline = true
vim.api.nvim_create_augroup('NoCursorline', {})
vim.api.nvim_create_autocmd('TermOpen', {
    pattern = '*',
    group = 'NoCursorline',
    command = 'setlocal nocursorline',
    desc = 'disable cursorline for terminal buffers',
})

-- highlight yanked text
vim.api.nvim_create_augroup('LuaHighlight', {})
vim.api.nvim_create_autocmd('TextYankPost', {
    pattern = '*',
    group = 'LuaHighlight',
    command = 'silent! lua vim.highlight.on_yank()',
    desc = 'highlight yanked text',
})

-- disable builit in plugins
local builtin_plugins = {
    -- we're actually using these:
    -- 'matchit',
    -- 'matchparen',
    -- '2html_plugin',

    'gzip',
    'zip',
    'zipPlugin',
    'tar',
    'tarPlugin',
    'getscript',
    'getscriptPlugin',
    'vimball',
    'vimballPlugin',
    'logiPat',
    'rrhelper',
    'netrw',
    'netrwPlugin',
    'netrwSettings',
    'netrwFileHandlers',
}

for _, plugin in ipairs(builtin_plugins) do
    vim.api.nvim_set_var('loaded_' .. plugin, 1)
end
