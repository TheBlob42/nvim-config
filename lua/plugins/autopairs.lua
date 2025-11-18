local autopairs = require('nvim-autopairs')

autopairs.setup {
    enable_check_bracket_line = true, -- don't add a pair if theres already a closing bracket in the same line
    map_cr = false, -- we have a custom mapping for this
    disable_filetype = { 'snacks_picker_input' },
}

-- remove adding single quotes for lisp filetypes
autopairs.get_rules("'")[1].not_filetypes = my.lisps
