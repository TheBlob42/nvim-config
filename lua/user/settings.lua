-- define leader keys as early as possible
vim.g.mapleader = ' '
vim.g.maplocalleader = ' m'

vim.opt.mouse = 'a'

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.number = true
vim.opt.signcolumn = 'number'

-- sync with system clipboard
vim.opt.clipboard = { 'unnamed', 'unnamedplus' }

-- `vim-sleuth` might overwrite these
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.confirm = true

vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.listchars = {
    eol = '⮯',
    tab = '<.>',
    trail = '~',
    extends = '➦',
    precedes = '⮪',
    space = '·',
}

vim.opt.completeopt = { 'menuone', 'noselect' }

vim.opt.timeoutlen = 500 -- for `which-key`
vim.opt.updatetime = 400 -- speed up 'cursorhold' events

vim.g.markdown_folding = 1 -- see 'ft-markdown-plugin'

-- opt in the new lua filetype detection
-- https://github.com/neovim/neovim/pull/16600
vim.g.do_filetype_lua = 1
vim.g.did_load_filetypes = 0

-- enable cursorline (except for terminal buffers)
vim.opt.cursorline = true
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
