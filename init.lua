require('user.settings')     -- general non plugin related settings
require('user.config')       -- general configuration stuff

-- local user configuration (if present)
if not pcall(require, 'user.local') then
    vim.api.nvim_err_writeln('No system local configuration found! Check "lua/user/local.lua.sample" for more information...')
end

-- must be loaded before any other lua plugin
local impatient_ok, impatient = pcall(require, 'impatient')
if impatient_ok then
    impatient.enable_profile()
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~
-- packer config & utilities
-- ~~~~~~~~~~~~~~~~~~~~~~~~~

-- automatically install packer
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local bootstrapping = vim.fn.isdirectory(install_path) ~= 1
if bootstrapping then
    vim.api.nvim_command('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
    vim.cmd.packadd('packer.nvim')
end

local packer = require('packer')
local snapshot_path = vim.fn.stdpath('config')

---Simple wrapper to ensure the config function is only called AFTER bootstrapping
local function wrap(fn)
    if not bootstrapping then
        return fn
    end
end

---Load the default configuration file from the "plugins" directory
local function load_config_file()
    if not bootstrapping then
        return function(plugin_name)
            local name = plugin_name
                :lower()              -- looking at you LuaSnip ;-)
                :gsub('^n?vim%-', '') -- remove "vim-" or "nvim-" prefix
                :gsub('%.n?vim$', '') -- remove ".vim" or ".nvim" postfix

            require('plugins.' .. name)
        end
    end
end

-- automatically re-source and compile when plugins.lua is updated
local packer_group = vim.api.nvim_create_augroup('Packer', {})
vim.api.nvim_create_autocmd('BufWritePost', {
    group = packer_group,
    command = 'source <afile> | PackerCompile',
    pattern = vim.env.MYVIMRC,
})

-- format the given snapshot using 'jq'
vim.api.nvim_create_user_command('PackerSnapshotFormat', function(args)
    if vim.fn.executable('jq') == 0 then
        vim.api.nvim_echo({{ "'jq' was not found in PATH, install it in order to use this command!" , 'ErrorMsg'}}, false, {})
        return
    end

    local snapshot = args.args
    local path = snapshot_path .. '/' .. snapshot
    local tmp = snapshot_path .. '/tmp_' .. snapshot

    if not vim.loop.fs_stat(path) then
        vim.api.nvim_echo({{ "No snapshot named '"..snapshot.."' exists in "..snapshot_path..'!', 'WarningMsg'}}, false, {})
        return
    end

    os.execute('jq --sort-keys . ' .. path .. ' > ' .. tmp)
    os.rename(tmp, path)
    vim.api.nvim_echo({{ "Snapshot '"..snapshot.."' formatted successfully", 'InfoMsg'}}, false, {})
end, { nargs = 1, desc = "format the given snapshot using 'jq'" })

packer.startup({function(use)
    use 'wbthomason/packer.nvim'

    use 'lewis6991/impatient.nvim' -- improve startup time for Neovim
    use 'tpope/vim-surround'       -- easy "surroundings"
    use 'tpope/vim-repeat'         -- repeat plug mappings with '.'
    use 'tpope/vim-sleuth'         -- auto configure `shiftwidth`
    use 'tpope/vim-abolish'        -- working with variant of words

    use {
        -- fuzzy find stuff using `fzf`
        'ibhagwan/fzf-lua',
        requires = 'kyazdani42/nvim-web-devicons',
        config = load_config_file(),
    }

    use {
        -- sneak like motion plugin
        'ggandor/leap.nvim',
        config = load_config_file(),
    }

    use {
        -- clever-f built on leap.nvim
        'ggandor/flit.nvim',
        config = wrap(function()
            require('flit').setup()
        end),
    }

    use {
        -- improve default ui interface
        'stevearc/dressing.nvim',
        config = load_config_file(),
    }

    use {
        -- "gc" to comment regions and lines
        'tpope/vim-commentary',
        config = load_config_file(),
    }

    use {
        -- pretty tabs and easy renaming
        'seblj/nvim-tabline',
        commit = '49a5651',
        config = load_config_file(),
    }

    use {
        -- two char escape sequence
        'TheBlob42/houdini.nvim',
        config = wrap(function()
            require('houdini').setup {
                mappings = { 'fd' }
            }
        end),
    }

    use {
        -- indent guides for all lines
        'lukas-reineke/indent-blankline.nvim',
        config = load_config_file(),
    }

    use {
        -- fancy notifications
        'rcarriga/nvim-notify',
        config = load_config_file(),
    }

    use {
        -- insert parentheses, brackets & quotes in pairs
        'windwp/nvim-autopairs',
        config = load_config_file(),
    }

    use {
        -- display possible key bindings in a popup
        'folke/which-key.nvim',
        config = load_config_file(),
    }

    use {
        -- interactive code evaluation
        'Olical/conjure',
        ft = my.lisps,
    }

    use {
        -- parinfer for Neovim
        'gpanders/nvim-parinfer',
        ft = my.lisps,
        cmd = { 'ParinferOn', 'ParinferToggle' },
    }

    -- TREESITTER
    use {
        'nvim-treesitter/nvim-treesitter',
        run = function()
            require('nvim-treesitter.install').update({ with_sync = true })()
        end,
        config = load_config_file(),
    }

    -- COLORSCHEME & STATUSLINE
    use {
        "catppuccin/nvim",
        as = "catppuccin",
        config = load_config_file(),
    }

    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons' },
        config = load_config_file(),
    }

    -- GIT
    use {
        -- git information integration
        'lewis6991/gitsigns.nvim',
        requires = 'nvim-lua/plenary.nvim',
        config = load_config_file(),
    }

    use {
        -- show git blame
        'f-person/git-blame.nvim',
        cmd = 'GitBlameToggle',
    }

    use {
        -- call 'lazygit' from within nvim
        'kdheepak/lazygit.nvim',
        branch = 'main',
        cmd = 'LazyGit',
        module = 'lazygit',
    }

    use {
        -- create shareable file permalinks
        'ruifm/gitlinker.nvim',
        requires = 'nvim-lua/plenary.nvim',
        module = 'gitlinker',
        config = load_config_file(),
    }

    -- LSP
    use {
        -- install external dependencies (LSP servers, DAP servers, etc.)
        'williamboman/mason.nvim',
        run = ':MasonUpdate',
    }
    use 'williamboman/mason-lspconfig.nvim'    -- make integration of mason.nvim and lspconfig easier

    use 'folke/neodev.nvim'                    -- special configuration for Lua (NVIM development)
    use 'onsails/lspkind-nvim'                 -- add icons to completion candidates
    use {
        -- special LSP configuration for Java
        'mfussenegger/nvim-jdtls',
        commit = '34202bc', -- keep support with JDK 11
    }
    use 'jose-elias-alvarez/nvim-lsp-ts-utils' -- special configuration for Type/Javascript
    use 'neovim/nvim-lspconfig'                -- "general" LSP configuration

    use {
        -- show lsp progress
        'j-hui/fidget.nvim',
        config = wrap(function()
            require('fidget').setup {
                text = { spinner = 'dots' }
            }
        end),
    }

    -- DAP
    use 'mfussenegger/nvim-dap' -- debug configuration (DAP)
    use 'rcarriga/nvim-dap-ui'  -- an "out-of-the-box" UI for dap

    -- SNIPPETS
    use 'rafamadriz/friendly-snippets'

    use {
        'L3MON4D3/LuaSnip',
        config = load_config_file(),
    }

    -- AUTO COMPLETION
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-cmdline'
    use 'saadparwaiz1/cmp_luasnip'
    use {
        'PaterJason/cmp-conjure',
        after = 'conjure',
    }

    use {
        'hrsh7th/nvim-cmp',
        config = load_config_file(),
    }

    -- UTILITIES
    use {
        -- 'svermeulen/vim-cutlass',
        -- separate "cut" from "delete"
        'TheBlob42/vim-cutlass',
        config = wrap(function()
            vim.g.CutlassRecursiveSelectBindings = 1 -- make it work with "autopairs"
            vim.keymap.set('x', 'x', 'd')            -- "cut operation" for visual mode
        end),
    }

    use {
        -- change VIM working dir to project root
        'airblade/vim-rooter',
        config = wrap(function()
            vim.g.rooter_patterns =  { '.git', '_darcs', '.hg', '.bzr', '.svn', 'Makefile' }
            vim.g.rooter_change_directory_for_non_project_files = 'current'
        end),
    }

    use {
        -- simple terminal manager
        'voldikss/vim-floaterm',
        cmd = { 'FloatermToggle', 'FloatermShow' },
    }

    use {
        -- edit files with sudo privileges
        'lambdalisue/suda.vim',
        cmd = { 'SudaRead', 'SudaWrite' }
    }

    use {
        -- delete buffers without messing up the window layout
        'famiu/bufdelete.nvim',
        cmd = { 'Bdelete', 'Bwipeout' },
    }

    use {
        -- preview markdown in your browser
        'iamcco/markdown-preview.nvim',
        ft = 'markdown',
        run = function()
            vim.fn['mkdp#util#install']()
        end,
    }

    use {
        -- undo history visualizer
        'mbbill/undotree',
        cmd = 'UndotreeToggle',
    }

    use {
        -- simple alignment plugin
        'junegunn/vim-easy-align',
        keys = '<Plug>(EasyAlign)',
    }

    use {
        -- measure NVIMs startup time
        'dstein64/vim-startuptime',
        cmd = 'StartupTime',
    }

    use {
        -- file/directory explorer
        'TheBlob42/drex.nvim',
        branch = 'develop', -- always testing the bleeding edge
        requires = { 'kyazdani42/nvim-web-devicons' },
        config = load_config_file(),
    }

    use {
        -- handle groovy indent correctly
        'modille/groovy.vim',
        ft = 'groovy',
    }

    use {
        -- perform diffs only on parts of a buffer
        'AndrewRadev/linediff.vim',
        cmd = 'Linediff',
    }
end,
config = {
    snapshot_path = snapshot_path,
}})

-- when bootstrapping the configuration we can stop here to avoid errors because of non-present plugins
if bootstrapping then
    packer.sync()
    print '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    print '        Plugins are being installed...'
    print '   Wait until completion then restart nvim'
    print '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    return
end

-- load all custom user commands from "lua/user/commands"
for name, _ in vim.fs.dir(vim.fn.fnamemodify(vim.env.MYVIMRC, ':h') .. '/lua/user/commands') do
    local cmd = string.match(name, '(.*)%.lua')
    if cmd ~= 'init' then
        require('user.commands.'..cmd)
    end
end

require('user.keymaps')
require('lsp')
