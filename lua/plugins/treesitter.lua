require('nvim-treesitter.configs').setup {
    ensure_installed = "all",
    highlight = {
        enable = true,
        disable = function(lang, buf)
            -- disable highlighting for certain file types
            -- help     : https://github.com/nvim-treesitter/nvim-treesitter/pull/3555
            -- vimdoc   : same as the "old" help filetype
            if vim.tbl_contains({ 'help', 'vimdoc' }, lang) then
                return true
            end

            -- disable highlighting for big markdown files (bad performance)
            if lang == 'markdown' and vim.api.nvim_buf_line_count(buf) > 3000 then
                return true
            end

            -- disable highlighting for large buffers
            if vim.api.nvim_buf_line_count(buf) > 30000 then
                return true
            end

            return false
        end,
    },
}
