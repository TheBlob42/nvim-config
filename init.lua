require('user.settings') -- general non plugin related settings
require('user.config')   -- general configuration stuff

require('user.plugins.statusline') -- custom statusline
require('user.plugins.tabline')    -- custom tabline
require('user.plugins.clever-f')   -- "clever-f" like functionality
require('user.plugins.rooter')     -- set cwd to "project" root automatically

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

---Utility function which just returns a function requiring the specific plugin module
---@param module string The configuration module to require (must reside in the "plugin" folder)
---@return function config-fn A proper configuration function being used with lazy.nvim package manager
local function plugin_config(module)
    return function()
        require('plugins.' .. module)
    end
end

require('lazy').setup({
    'tpope/vim-surround', -- easy "surroundings"
    'tpope/vim-repeat',   -- repeat plug mappings with '.'
    'tpope/vim-sleuth',   -- auto configure `shiftwidth`

    {
        -- provide icons and colors
        'kyazdani42/nvim-web-devicons',
        lazy = true,
    },

    {
        -- fuzzy find stuff using `fzf`
        'ibhagwan/fzf-lua',
        config = plugin_config('fzf-lua'),
    },

    {
        -- sneak like motion plugin
        'ggandor/leap.nvim',
        config = plugin_config('leap'),
    },

    {
        -- "gc" to comment regions and lines
        'tpope/vim-commentary',
        config = plugin_config('commentary'),
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
        config = plugin_config('indent-blankline'),
    },

    {
        -- fancy notifications
        'rcarriga/nvim-notify',
        config = plugin_config('notify'),
    },

    {
        -- insert parentheses, brackets & quotes in pairs
        'windwp/nvim-autopairs',
        config = plugin_config('autopairs'),
    },

    {
        -- display possible key bindings in a popup
        'folke/which-key.nvim',
        config = plugin_config('which-key'),
    },

    {
        -- interactive code evaluation
        'Olical/conjure',
        ft = my.lisps,
        init = plugin_config('conjure'),
        config = function()
            require("conjure.main").main()
            require("conjure.mapping")["on-filetype"]()
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
        config = plugin_config('treesitter'),
    },

    -- COLORSCHEME
    {
        'miikanissi/modus-themes.nvim',
        config = plugin_config('modus'),
    },

    -- GIT
    {
        -- git information integration
        'lewis6991/gitsigns.nvim',
        dependencies = 'nvim-lua/plenary.nvim',
        config = plugin_config('gitsigns'),
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
        config = plugin_config('gitlinker'),
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
    'mfussenegger/nvim-jdtls',              -- special LSP configuration for Java
    'jose-elias-alvarez/nvim-lsp-ts-utils', -- special configuration for Type/Javascript
    'neovim/nvim-lspconfig',                -- "general" LSP configuration

    {
        -- show lsp progress
        'j-hui/fidget.nvim',
        config = function()
            require('fidget').setup {
                progress = {
                    display = {
                        render_limit = 6
                    }
                }
            }
        end,
    },

    -- DAP
    'mfussenegger/nvim-dap', -- debug configuration (DAP)
    'rcarriga/nvim-dap-ui',  -- an "out-of-the-box" UI for dap

    -- SNIPPETS

    {
        'L3MON4D3/LuaSnip',
        config = plugin_config('luasnip'),
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
        config = plugin_config('cmp'),
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
        -- file/directory explorer
        'TheBlob42/drex.nvim',
        branch = 'develop', -- always testing the bleeding edge
        config = plugin_config('drex'),
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
}, {
    ui = { border = 'single' }
})

-- load all custom user commands from "lua/user/commands"
for name, _ in vim.fs.dir(vim.fn.fnamemodify(vim.env.MYVIMRC, ':h') .. '/lua/user/commands') do
    local cmd = string.match(name, '(.*)%.lua')
    if cmd ~= 'init' then
        require('user.commands.'..cmd)
    end
end

require('user.keymaps')
require('lsp')
