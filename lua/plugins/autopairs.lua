local autopairs = require('nvim-autopairs')

autopairs.setup {
    -- don't add a pair if theres already a closing bracket in the same line
    enable_check_bracket_line = true
}

-- setup for `nvim-cmp`
require('cmp').event:on('confirm_done', require('nvim-autopairs.completion.cmp').on_confirm_done {
    map_char = { tex = '' }
})

-- remove adding single quotes for lisp filetypes
autopairs.get_rules("'")[1].not_filetypes = my.lisps
