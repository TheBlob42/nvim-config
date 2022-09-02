local status_ok, blankline = my.req('indent_blankline')
if not status_ok then
    return
end

blankline.setup {
    buftype_exclude = { 'terminal' },
    filetype_exclude = {
        'help',
        'packer',
    },
    viewport_buffer = 30,
    use_treesitter = true,
    show_current_context = true,
    show_current_context_start = true,
    context_patterns = {
        "^func",
        "function",
        "class",
        "method",
        "^if",
        "if_statement",
        "else_clause",
        "while",
        "for",
        "^for",
        "with",
        "try",
        "try_statement",
        "catch_clause",
        "except",
        "arguments",
        "argument_list",
        "object",
        "^object",
        "dictionary",
        "element",
        "table",
        "^table",
        "tuple",
        "return",
        "^while",
        "jsx_element",
        "jsx_self_closing_element",
        "block",
        "import_statement",
        "operation_type",
    },
}
