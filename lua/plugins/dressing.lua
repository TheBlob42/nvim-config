require('dressing').setup {
    select = {
        backend = { 'fzf_lua', 'telescope', 'builtin' },
        fzf_lua = {
            winopts = {
                width = 0.8,
                height = 0.4,
            }
        },
    }
}
