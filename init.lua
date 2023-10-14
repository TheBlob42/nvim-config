require('user.settings')   -- general non plugin related settings
require('user.config')     -- general configuration stuff
require('user.statusline') -- custom statusline
require('user.tabline')    -- custom tabline

-- local user configuration (if present)
if not pcall(require, 'user.local') then
    vim.api.nvim_err_writeln('No system local configuration found! Check "lua/user/local.lua.sample" for more information...')
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- lazy.nvim config & utilities
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- automatically install lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    }
end
vim.opt.runtimepath:prepend(lazypath)

---Utility function to automatically load the "appropriate" configuration from the plugin directory
---@param plugin table The plugin specification by lazy.nvim
local function load_config_file(plugin)
    -- use custom name over "regular" name over local directory
    local name = plugin.name or plugin[1] or plugin.dir

    name = name
        :lower()              -- looking at you LuaSnip ;-)
        :gsub('.*/', '')      -- remove file system path prefix
        :gsub('^n?vim%-', '') -- remove "vim-" or "nvim-" prefix
        :gsub('%.n?vim$', '') -- remove ".vim" or ".nvim" postfix

    require('plugins.'..name)
end

require('lazy').setup {
    'tpope/vim-surround', -- easy "surroundings"
    'tpope/vim-repeat',   -- repeat plug mappings with '.'
    'tpope/vim-sleuth',   -- auto configure `shiftwidth`
    'tpope/vim-abolish',  -- working with variant of words

    {
        -- provide icons and colors
        'kyazdani42/nvim-web-devicons',
        lazy = true,
    },

    {
        -- fuzzy find stuff using `fzf`
        'ibhagwan/fzf-lua',
        config = load_config_file,
    },

    {
        -- sneak like motion plugin
        'ggandor/leap.nvim',
        config = load_config_file,
    },

    {
        -- clever-f built on leap.nvim
        'ggandor/flit.nvim',
        config = function()
            require('flit').setup()
        end,
    },

    {
        -- improve default ui interface
        'stevearc/dressing.nvim',
        config = load_config_file,
    },

    {
        -- "gc" to comment regions and lines
        'tpope/vim-commentary',
        config = load_config_file,
    },

    {
        -- two char escape sequence
        'TheBlob42/houdini.nvim',
        config = function()
            require('houdini').setup {
                mappings = { 'fd' }
            }
        end,
    },

    {
        -- indent guides for all lines
        'lukas-reineke/indent-blankline.nvim',
        config = load_config_file,
    },

    {
        -- fancy notifications
        'rcarriga/nvim-notify',
        config = load_config_file,
    },

    {
        -- insert parentheses, brackets & quotes in pairs
        'windwp/nvim-autopairs',
        config = load_config_file,
    },

    {
        -- display possible key bindings in a popup
        'folke/which-key.nvim',
        config = load_config_file,
    },

    {
        -- interactive code evaluation
        'Olical/conjure',
        ft = my.lisps,
        config = function()
            require("conjure.main").main()
            require("conjure.mapping")["on-filetype"]()
        end,
        init = function()
            vim.g['conjure#filetypes'] = my.lisps
            vim.g['conjure#filetype#fennel'] = 'conjure.client.fennel.stdio'

            -- disable diagnostics for the log buffer as they contain "non-valid" clojure parts
            vim.api.nvim_create_autocmd('BufNewFile', {
                group = vim.api.nvim_create_augroup('ConjureLogDisableDiagnostic', {}),
                pattern = { 'conjure-log-*' },
                callback = function()
                    vim.diagnostic.disable(0)
                end,
                desc = 'disable diagnostics for conjure log buffer',
            })
        end,
        dependencies = { 'PaterJason/cmp-conjure' }
    },

    {
        -- parinfer for Neovim
        'gpanders/nvim-parinfer',
        init = function()
            vim.g.parinfer_filetypes = my.lisps
        end,
    },

    -- TREESITTER
    {
        'nvim-treesitter/nvim-treesitter',
        build = function()
            require('nvim-treesitter.install').update({ with_sync = true })()
        end,
        config = load_config_file,
    },

    -- COLORSCHEME & STATUSLINE
    {
        "catppuccin/nvim",
        name = "catppuccin",
        config = load_config_file,
    },

    -- GIT
    {
        -- git information integration
        'lewis6991/gitsigns.nvim',
        dependencies = 'nvim-lua/plenary.nvim',
        config = load_config_file,
    },

    {
        -- show git blame
        'f-person/git-blame.nvim',
        cmd = 'GitBlameToggle',
        init = function()
            vim.g.gitblame_enabled = 0 -- disable by default
            vim.keymap.set('n', '<leader>gb', '<CMD>GitBlameToggle<CR>', { desc = 'git blame' })
        end,
    },

    {
        -- call 'lazygit' from within nvim
        'kdheepak/lazygit.nvim',
        branch = 'main',
        cmd = 'LazyGit',
        init = function()
            if vim.fn.executable('nvr') then
                -- use as git commit message editor
                vim.env.GIT_EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
            end

            vim.keymap.set('n', '<leader>gg', function()
                -- to also make it work inside of non-file buffers (e.g. file manager)
                require('lazygit').lazygit(vim.fn.getcwd())
            end, { desc = 'open lazygit'})
        end,
    },

    {
        -- create shareable file permalinks
        'ruifm/gitlinker.nvim',
        dependencies = 'nvim-lua/plenary.nvim',
        config = load_config_file,
        init = function()
            vim.keymap.set('n', '<leader>gy', function()
                require('gitlinker').get_buf_range_url('n')
            end, { desc = 'copy git permalink' })

            vim.keymap.set('v', '<leader>gy', function()
                require('gitlinker').get_buf_range_url('v')
            end, { desc = 'copy git permalink' })
        end,
    },

    -- LSP
    {
        -- install external dependencies (LSP servers, DAP servers, etc.)
        'williamboman/mason.nvim',
        build = ':MasonUpdate',
    },
    'williamboman/mason-lspconfig.nvim',    -- make integration of mason.nvim and lspconfig easier

    'folke/neodev.nvim',                    -- special configuration for Lua (NVIM development)
    'onsails/lspkind-nvim',                 -- add icons to completion candidates
    {
        -- special LSP configuration for Java
        'mfussenegger/nvim-jdtls',
        commit = '34202bc', -- keep support with JDK 11
    },
    'jose-elias-alvarez/nvim-lsp-ts-utils', -- special configuration for Type/Javascript
    'neovim/nvim-lspconfig',                -- "general" LSP configuration

    {
        -- show lsp progress
        'j-hui/fidget.nvim',
        tag = 'legacy',
        config = function()
            require('fidget').setup {
                text = { spinner = 'dots' }
            }
        end,
    },

    -- DAP
    'mfussenegger/nvim-dap', -- debug configuration (DAP)
    'rcarriga/nvim-dap-ui',  -- an "out-of-the-box" UI for dap

    -- SNIPPETS

    {
        'L3MON4D3/LuaSnip',
        config = load_config_file,
        dependencies = { 'rafamadriz/friendly-snippets' }
    },

    -- AUTO COMPLETION
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'saadparwaiz1/cmp_luasnip',
    {
        'hrsh7th/nvim-cmp',
        config = load_config_file,
    },

    -- UTILITIES
    {
        -- separate "cut" from "delete"
        'TheBlob42/vim-cutlass',
        config = function()
            vim.g.CutlassRecursiveSelectBindings = 1 -- make it work with "autopairs"
            vim.keymap.set('x', 'x', 'd')            -- "cut operation" for visual mode
        end,
    },

    {
        -- change VIM working dir to project root
        'airblade/vim-rooter',
        config = function()
            vim.g.rooter_patterns =  { '.git', '_darcs', '.hg', '.bzr', '.svn', 'Makefile', '.marksman.toml' }
            vim.g.rooter_change_directory_for_non_project_files = 'current'
        end,
    },

    {
        -- simple terminal manager
        'voldikss/vim-floaterm',
        cmd = { 'FloatermToggle', 'FloatermShow' },
        init = function()
            -- configuration for the floating terminal window
            vim.g.floaterm_width      = 0.75
            vim.g.floaterm_height     = 0.75
            vim.g.floaterm_autoinsert = false

            vim.keymap.set('n', "<leader>'", '<CMD>FloatermToggle<CR>', { desc = 'toggle terminal' })
        end,
    },

    {
        -- edit files with sudo privileges
        'lambdalisue/suda.vim',
        cmd = { 'SudaRead', 'SudaWrite' },
        init = function()
            vim.keymap.set('n', '<leader>fer', '<CMD>SudaRead<CR>', { desc = 'sudo read' })
            vim.keymap.set('n', '<leader>few', '<CMD>SudaWrite<CR>', { desc = 'sudo write' })
        end,
    },

    {
        -- delete buffers without messing up the window layout
        'famiu/bufdelete.nvim',
        cmd = { 'Bdelete', 'Bwipeout' },
        init = function()
            vim.keymap.set('n', '<leader>bd', '<CMD>Bdelete<CR>', { desc = 'delete buffer' })
            vim.keymap.set('n', '<leader>bD', '<CMD>Bdelete!<CR>', { desc = 'force delete buffer' })
        end,
    },

    {
        -- preview markdown in your browser
        'iamcco/markdown-preview.nvim',
        ft = 'markdown',
        build = function()
            vim.fn['mkdp#util#install']()
        end,
    },

    {
        -- undo history visualizer
        'mbbill/undotree',
        cmd = 'UndotreeToggle',
        init = function()
            vim.g.undotree_WindowLayout = 4
            vim.g.undotree_SetFocusWhenToggle = 1

            vim.keymap.set('n', '<leader>U', '<CMD>UndotreeToggle<CR>', { desc = 'undo tree' })
        end,
    },

    {
        -- simple alignment plugin
        'junegunn/vim-easy-align',
        keys = '<Plug>(EasyAlign)',
        init = function()
            vim.keymap.set('x', 'ga', '<Plug>(EasyAlign)', { desc = 'easy align' })
            vim.keymap.set('n', 'ga', '<Plug>(EasyAlign)', { desc = 'easy align' })
        end,
    },

    {
        -- measure NVIMs startup time
        'dstein64/vim-startuptime',
        cmd = 'StartupTime',
    },

    {
        -- file/directory explorer
        'TheBlob42/drex.nvim',
        branch = 'develop', -- always testing the bleeding edge
        config = load_config_file,
    },

    {
        -- handle groovy indent correctly
        'modille/groovy.vim',
        ft = 'groovy',
    },

    {
        -- perform diffs only on parts of a buffer
        'AndrewRadev/linediff.vim',
        cmd = 'Linediff',
    },
}

-- load all custom user commands from "lua/user/commands"
for name, _ in vim.fs.dir(vim.fn.fnamemodify(vim.env.MYVIMRC, ':h') .. '/lua/user/commands') do
    local cmd = string.match(name, '(.*)%.lua')
    if cmd ~= 'init' then
        require('user.commands.'..cmd)
    end
end

require('user.keymaps')
require('lsp')
