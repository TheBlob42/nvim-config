require('indent_blankline').setup {
    buftype_exclude = { 'terminal' },
    filetype_exclude = {
        'help',
        'packer',
        'mason',
    },
    viewport_buffer = 30,
    use_treesitter = true,
    show_current_context = true,
    show_current_context_start = true,
}
