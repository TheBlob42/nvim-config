-- automatically install packer
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local first_install = vim.fn.isdirectory(install_path) ~= 1
if first_install then
    vim.api.nvim_command('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
    vim.cmd('packadd packer.nvim')
end

-- automatically re-source and compile when plugins.lua is updated
local packer_group = vim.api.nvim_create_augroup('Packer', {})
vim.api.nvim_create_autocmd('BufWritePost', {
    pattern = 'plugins.lua',
    command = 'luafile %',
    group = packer_group,
})
vim.api.nvim_create_autocmd('BufWritePost', {
    pattern = 'plugins.lua',
    command = 'PackerCompile',
    group = packer_group,
})

-- simple helper to load configuration
local function load_config(mod)
    require(mod)
end

local packer = require('packer')
local snapshot_path = vim.fn.stdpath('config')

packer.startup({function(use)
    use 'wbthomason/packer.nvim'

    use 'lewis6991/impatient.nvim' -- improve startup time for Neovim
    use 'tpope/vim-surround'       -- easy "surroundings"
    use 'tpope/vim-repeat'         -- repeat plug mappings with '.'
    use 'tpope/vim-sleuth'         -- auto configure `shiftwidth`
    use 'tpope/vim-abolish'        -- working with variant of words
    use 'ggandor/lightspeed.nvim'  -- sneak like motion plugin

    use {
        -- improve default ui interface
        'stevearc/dressing.nvim',
        config = load_config('plugins.dressing'),
    }

    use {
        -- "gc" to comment regions and lines
        'tpope/vim-commentary',
        config = load_config('plugins.commentary'),
    }

    use {
        -- pretty tabs and easy renaming
        'seblj/nvim-tabline',
        commit = '49a5651',
        config = load_config('plugins.tabline'),
    }

    use {
        -- two char escape sequence
        'TheBlob42/houdini.nvim',
        config = load_config('plugins.houdini'),
    }

    use {
        -- indent guides for all lines
        'lukas-reineke/indent-blankline.nvim',
        config = load_config('plugins.blankline'),
    }

    use {
        -- fancy notifications
        'rcarriga/nvim-notify',
        config = load_config('plugins.notify'),
    }

    use {
        -- insert parentheses, brackets & quotes in pairs
        'windwp/nvim-autopairs',
        config = load_config('plugins.autopairs'),
    }

    use {
        -- display possible key bindings in a popup
        'folke/which-key.nvim',
        config = load_config('plugins.whichkey'),
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
        run = ':TSUpdate',
        config = load_config('plugins.treesitter'),
    }
    -- use 'JoosepAlviste/nvim-ts-context-commentstring'
    -- use 'windwp/nvim-ts-autotag'

    -- COLORSCHEME & STATUSLINE
    use {
        'projekt0n/github-nvim-theme',
        config = load_config('plugins.github_theme'),
    }

    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons' },
        config = load_config('plugins.lualine'),
    }

    -- GIT
    use {
        -- git information integration
        'lewis6991/gitsigns.nvim',
        requires = 'nvim-lua/plenary.nvim',
        config = load_config('plugins.gitsigns'),
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

    -- TELESCOPE
    use {
        'nvim-telescope/telescope.nvim',
        requires = 'nvim-lua/plenary.nvim',
        config = load_config('plugins.telescope'),
    }

    use 'nvim-telescope/telescope-project.nvim'
    use 'nvim-telescope/telescope-file-browser.nvim'

    use {
        'nvim-telescope/telescope-fzf-native.nvim',
        run = 'make',
    }

    -- LSP
    use 'j-hui/fidget.nvim'                    -- show lsp progress
    use 'williamboman/nvim-lsp-installer'      -- install LSP servers easily
    use 'folke/lua-dev.nvim'                   -- special configuration for Lua (NVIM development)
    use 'onsails/lspkind-nvim'                 -- add icons to completion candidates
    use 'mfussenegger/nvim-jdtls'              -- special configuration for Java
    use 'jose-elias-alvarez/nvim-lsp-ts-utils' -- special configuration for Type/Javascript
    use 'neovim/nvim-lspconfig'                -- "general" LSP configuration

    -- DAP
    use 'mfussenegger/nvim-dap' -- debug configuration (DAP)
    use 'rcarriga/nvim-dap-ui'  -- an "out-of-the-box" UI for dap

    -- SNIPPETS
    use 'rafamadriz/friendly-snippets'

    use {
        'L3MON4D3/LuaSnip',
        config = load_config('plugins.luasnip'),
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
        config = load_config('plugins.cmp'),
    }

    -- UTILITIES
    use {
        -- 'svermeulen/vim-cutlass',
        -- separate "cut" from "delete"
        'TheBlob42/vim-cutlass',
        config = function()
            vim.g.CutlassRecursiveSelectBindings = 1 -- make it work with "autopairs"
            vim.keymap.set('x', 'x', 'd')            -- "cut operation" for visual mode
        end,
    }

    use {
        -- change VIM working dir to project root
        'airblade/vim-rooter',
        config = function()
            vim.g.rooter_patterns =  { '.git', '_darcs', '.hg', '.bzr', '.svn', 'Makefile' }
            vim.g.rooter_change_directory_for_non_project_files = 'current'
        end,
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
        requires = { 'kyazdani42/nvim-web-devicons' },
        config = load_config('plugins.drex'),
    }

    use {
        -- handle groovy indent correctly
        'modille/groovy.vim',
        ft = 'groovy',
    }
end,
config = {
    compile_path = vim.fn.stdpath('config') .. '/lua/packer_compiled.lua',
    snapshot_path = snapshot_path,
}})

if first_install then
    packer.sync()
    vim.api.nvim_create_autocmd('User', {
        once = true,
        pattern = 'PackerComplete',
        callback = function()
            local yes, no = 'Yes, quit now', 'No, not now'
            vim.ui.select({ yes, no },
                {
                    prompt = 'Install complete, please restart Neovim'
                },
                function(choice)
                    if choice == yes then
                        vim.cmd('quitall')
                    end
                end
            )
        end,
    })
end

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
