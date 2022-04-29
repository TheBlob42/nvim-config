local status_ok, treesitter = my.req('nvim-treesitter.configs')
if not status_ok then
    return
end

treesitter.setup {
    ensure_installed = "all",
    ignore_install = {
        'help',
        'markdown'
    },
    highlight = {
        enable = true,
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
