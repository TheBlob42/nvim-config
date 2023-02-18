require('nvim-treesitter.configs').setup {
    ensure_installed = "all",
    highlight = {
        enable = true,
        disable = function(lang, buf)
            -- disable highlighting for certain file types:
            -- > help: https://github.com/nvim-treesitter/nvim-treesitter/pull/3555
            if vim.tbl_contains({ 'help' }, lang) then
                return true
            end

            -- disable highlighting for large buffers
            return vim.api.nvim_buf_line_count(buf) > 30000
        end,
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "<CR>",
            node_incremental = "<CR>",
            scope_incremental = "<TAB>",
            node_decremental = "<BS>",
        },
    },
}
