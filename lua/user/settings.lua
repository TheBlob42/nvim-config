-- define leader keys as early as possible
vim.g.mapleader = ' '
vim.g.maplocalleader = ' m'

vim.opt.mouse = 'a'

vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.splitkeep = 'screen'

vim.opt.number = false
vim.opt.numberwidth = 2

vim.opt.signcolumn = 'auto:1-2'

vim.opt.winborder = 'single'

vim.opt.title = true
vim.opt.titlestring = '%F'

-- sync with system clipboard
vim.opt.clipboard = { 'unnamed', 'unnamedplus' }

-- `vim-sleuth` might overwrite these
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.confirm = true
vim.opt.breakindent = true

vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.listchars = {
    eol = '',
    tab = '<.>',
    trail = '~',
    extends = '',
    precedes = '',
    space = '·',
}

vim.opt.timeoutlen = 500 -- for `which-key`
vim.opt.updatetime = 400 -- speed up 'cursorhold' events

vim.g.markdown_folding = 1 -- see 'ft-markdown-plugin'

-- to preserve the highlighting of the underlying text
vim.opt.foldtext = ''
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldcolumn = '0'
vim.opt.foldlevel = 99

vim.opt.cursorline = true

-- set background according to the current time ("dark mode" in the evening/night)
-- the colorscheme should take this into consideration automatically
local hour = os.date('*t').hour
if hour > 18 or hour < 8 then
    vim.opt.background = "dark"
else
    vim.opt.background = "light"
end

-- disable cursorline for terminal buffers
vim.api.nvim_create_autocmd('TermOpen', {
    group = vim.api.nvim_create_augroup('NoCursorline', {}),
    pattern = '*',
    command = 'setlocal nocursorline',
    desc = 'disable cursorline and signcolumn for terminal buffers',
})

-- highlight yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('LuaHighlight', {}),
    pattern = '*',
    command = 'silent! lua vim.highlight.on_yank()',
    desc = 'highlight yanked text',
})

-- mark diagnostics with the little "default squares"
vim.diagnostic.config {
    virtual_text = {
        format = function() return '' end,
        spacing = 0,
    },
    signs = false,
}

-- custom filetype detection
vim.filetype.add {
    extension = {
        ['cljd'] = 'clojure',
        ['tf'] = 'terraform',
        ['Jenkinsfile'] = 'groovy',
    },
    filename = {
        ['Jenkinsfile'] = 'groovy',
    }
}

-- disable builit in plugins
local builtin_plugins = {
    -- we're actually using these:
    -- 'matchit',
    -- 'matchparen',
    -- '2html_plugin',

    -- used for "zipfile://" links (e.g. clojure-lsp)
    -- 'zip',
    -- 'zipPlugin',

    'gzip',
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
