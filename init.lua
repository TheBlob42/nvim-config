require('user.settings') -- general non plugin related settings
require('user.config')   -- general configuration stuff

-- local user configuration (if present)
if not pcall(require, 'user.local') then
    vim.api.nvim_echo({ 'No system local configuration found! Check "lua/user/local.lua.sample" for more information...' }, true, { err = true })
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- lazy.nvim config & utilities
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- automatically bootstrap alpacka.nvim
local alpacka_path = vim.fn.stdpath('data') .. '/site/pack/alpacka/opt/alpacka.nvim'
if not vim.uv.fs_stat(alpacka_path) then
    local out = vim.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/theblob42/alpacka.nvim.git',
        alpacka_path,
    }):wait()

    if out.code ~= 0 then
      print('Error when cloning "alpacka.nvim":\n' .. out.stderr)
    end
end

vim.cmd.packadd('alpacka.nvim')

---Utility function which just returns a function requiring the specific plugin module
---@param module string The configuration module to require (must reside in the "plugin" folder)
---@return function config-fn A proper configuration function being used with lazy.nvim package manager
local function plugin_config(module)
    return function()
        require('plugins.' .. module)
    end
end

require('alpacka').setup {
    'theblob42/alpacka.nvim',

    'tpope/vim-surround', -- easy "surroundings"
    'tpope/vim-repeat',   -- repeat plug mappings with '.'
    'tpope/vim-sleuth',   -- auto configure `shiftwidth`

    'kyazdani42/nvim-web-devicons', -- provide icons and colors
    'nvim-lua/plenary.nvim', -- dependency for gitlinker

    {
        -- sneak like motion plugin
        'ggandor/leap.nvim',
        config = plugin_config('leap'),
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
        -- fancy notifications
        'rcarriga/nvim-notify',
        config = plugin_config('notify'),
    },

    {
        -- display possible key bindings in a popup
        'folke/which-key.nvim',
        config = plugin_config('which-key'),
    },

    {
        -- interactive code evaluation
        'theblob42/simple-repl.nvim',
    },

    {
        load = function()
            return vim.fn.executable('cargo') == 1
        end,
        'eraserhd/parinfer-rust',
        build = function()
            vim.system({ 'cargo', 'build', '--release' }):wait()
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
        config = plugin_config('gitsigns'),
    },

    {
        -- create shareable file permalinks
        'ruifm/gitlinker.nvim',
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
        build = function()
            require('mason-registry').refresh()
        end
    },
    'williamboman/mason-lspconfig.nvim',    -- make integration of mason.nvim and lspconfig easier

    {
        -- special configuration for Lua (NVIM development)
        'folke/lazydev.nvim',
        config = function()
            ---@diagnostic disable-next-line: missing-fields
            require('lazydev').setup {
                library = {
                  { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                  { path = 'snacks.nvim', words = { 'Snacks' } },
                },
            }
        end
    },
    'mfussenegger/nvim-jdtls', -- special LSP configuration for Java
    'neovim/nvim-lspconfig',   -- "general" LSP configuration

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
    },

    -- AUTO COMPLETION
    {
        'hrsh7th/nvim-cmp',
        config = plugin_config('cmp'),
    },
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'saadparwaiz1/cmp_luasnip',

    {
        -- insert parentheses, brackets & quotes in pairs
        'windwp/nvim-autopairs',
        config = plugin_config('autopairs'),
    },

    {
        'folke/snacks.nvim',
        config = plugin_config('snacks'),
    },

    {
        -- rest client that works with `.http` files
        'mistweaverco/kulala.nvim',
        config = function()
            -- usage setup in the `./after/ftplugin/http.lua` file
            require('kulala').setup()
        end,
    },

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
        config = function()
            vim.keymap.set('n', '<leader>fer', '<CMD>SudaRead<CR>', { desc = 'sudo read' })
            vim.keymap.set('n', '<leader>few', '<CMD>SudaWrite<CR>', { desc = 'sudo write' })
        end,
    },

    {
        -- preview markdown in your browser
        'iamcco/markdown-preview.nvim',
        build = function()
            vim.fn['mkdp#util#install']()
        end,
    },

    {
        'stevearc/oil.nvim',
        config = function()
            local oil = require('oil')
            oil.setup {
                buf_options = {
                    bufhidden = 'wipe'
                },
                columns = {
                    'size',
                    'icon',
                },
                view_options = {
                    show_hidden = true,
                },
                keymaps = {
                    ['<C-y>'] = { 'actions.yank_entry', mode = 'n' }
                }
            }
            vim.keymap.set('n', '-', oil.open, { desc = 'Open parent directory' })
            vim.keymap.set('n', '_', function()
                oil.open(vim.uv.cwd())
            end, { desc = 'Open current working directory' })
        end,
    },

    {
        -- make whitespace characters visible in visual mode
        'mcauley-penney/visual-whitespace.nvim',
        config = function()
            require('visual-whitespace').setup()
        end,
    },

    'modille/groovy.vim', -- handle groovy indent correctly
    "kongo2002/fsharp-vim", -- since there is no default syntax highlighting
    'AndrewRadev/linediff.vim', -- perform diffs only on parts of a buffer
}

-- load all custom user commands from "lua/user/commands"
for name, _ in vim.fs.dir(vim.fn.fnamemodify(vim.env.MYVIMRC, ':h') .. '/lua/user/commands') do
    local cmd = string.match(name, '(.*)%.lua')
    require('user.commands.'..cmd)
end

require('user.plugins') -- load custom user plugins
require('user.keymaps') -- general key mappings
require('lsp')          -- LSP setup
