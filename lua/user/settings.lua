-- define leader keys as early as possible
vim.g.mapleader = ' '
vim.g.maplocalleader = ' m'

vim.opt.mouse = 'a'

vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.splitkeep = 'screen'

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
    eol = '',
    tab = '<.>',
    trail = '~',
    extends = '',
    precedes = '',
    space = '·',
}

vim.opt.completeopt = { 'menuone', 'noselect' }

vim.opt.timeoutlen = 500 -- for `which-key`
vim.opt.updatetime = 400 -- speed up 'cursorhold' events

vim.g.markdown_folding = 1 -- see 'ft-markdown-plugin'

vim.opt.cursorline = true

-- set background according to the current time ("dark mode" in the evening/night)
-- the colorscheme should take this into consideration automatically
local hour = os.date('*t').hour
if hour > 18 or hour < 8 then
    vim.opt.background = "dark"
else
    vim.opt.background = "light"
end

-- disable cursorline and signcolumn for terminal buffers
vim.api.nvim_create_autocmd('TermOpen', {
    group = vim.api.nvim_create_augroup('NoCursorline', {}),
    pattern = '*',
    command = 'setlocal nocursorline signcolumn=no',
    desc = 'disable cursorline for terminal buffers',
})

-- highlight yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('LuaHighlight', {}),
    pattern = '*',
    command = 'silent! lua vim.highlight.on_yank()',
    desc = 'highlight yanked text',
})

vim.opt.numberwidth = 2
vim.opt.signcolumn = 'auto:2-5'

-- ###################
-- ### Diagnostics ###
-- ###################

vim.diagnostic.config {
    virtual_text = false
}

-- only show the "worst" diagnostic sign (highest severity, see ':h diagnostic-handlers-example')
local ns = vim.api.nvim_create_namespace('max_severity_only')
local orig_signs_handler = vim.diagnostic.handlers.signs

vim.diagnostic.handlers.signs = {
    show = function(_, bufnr, diagnostics, opts)
        local max_severity_per_line = {}
        for _, d in pairs(diagnostics) do
            local m = max_severity_per_line[d.lnum]
            if not m or d.severity < m.severity then
                max_severity_per_line[d.lnum] = d
            end
        end

        local filtered_diagnostics = vim.tbl_values(max_severity_per_line)
        orig_signs_handler.show(ns, bufnr, filtered_diagnostics, opts)
    end,
    hide = function(_, bufnr)
        orig_signs_handler.hide(ns, bufnr)
    end
}

-- define diagnostic icons and colors
vim.fn.sign_define("DiagnosticSignError", {
    text = "",
    texthl = "DiagnosticError",
    numhl = "DiagnosticError",
})
vim.fn.sign_define("DiagnosticSignWarn", {
    text = "",
    texthl = "DiagnosticWarn",
    numhl = "DiagnosticWarn",
})
vim.fn.sign_define("DiagnosticSignHint", {
    text = "",
    texthl = "DiagnosticHint",
    numhl = "DiagnosticHint",
})
vim.fn.sign_define("DiagnosticSignInfo", {
    text = "",
    texthl = "DiagnosticInformation",
    numhl = "DiagnosticInformation",
})

-- custom filetype detection
vim.filetype.add {
    extension = {
        ['cljd'] = 'clojure'
    },
    filename = {
        ['Jenkinsfile'] = 'groovy'
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
