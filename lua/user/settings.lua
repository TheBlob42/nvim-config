local opt = vim.opt
local cmd = vim.cmd

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

-- enable cursorline (except for terminal buffers)
opt.cursorline = true
cmd [[
    augroup nocursorline
        au!
        au termopen * lua vim.opt_local.cursorline = false
    augroup end
]]

vim.g.markdown_folding = 1 -- see 'ft-markdown-plugin'

-- opt in the new lua filetype detection
-- https://github.com/neovim/neovim/pull/16600
vim.g.do_filetype_lua = 1
vim.g.did_load_filetypes = 0

-- highlight yanked text
cmd [[
    augroup luahighlight
        au!
        au textyankpost * silent! lua vim.highlight.on_yank()
    augroup end
]]

---allows backspacing through previously set text in a "prompt" buffer
---https://github.com/neovim/neovim/issues/14116#issuecomment-977555102
function PromptBackspace()
    local currentcursor = vim.api.nvim_win_get_cursor(0)
    local currentlinenumber = currentcursor[1]
    local currentcolumnnumber = currentcursor[2]
    local promptlength = vim.str_utfindex(vim.fn['prompt_getprompt']('%'));

    if (currentcolumnnumber) ~= promptlength then
        vim.api.nvim_buf_set_text(0, currentlinenumber - 1, currentcolumnnumber - 1, currentlinenumber - 1, currentcolumnnumber, {""})
        vim.api.nvim_win_set_cursor(0, { currentlinenumber, currentcolumnnumber - 1 })
    end
end

-- not using a lua function because of error when accessing :help
cmd [[
    fun! PromptBackspaceSetup()
        if v:option_new == 'prompt'
            inoremap <buffer> <bs> <cmd>:lua PromptBackspace()<cr>
        endif
    endfun

    autocmd optionset * call PromptBackspaceSetup()
]]

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
