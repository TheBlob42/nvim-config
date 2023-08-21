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

-- add spaces between parentheses
--
-- | Before | Input | After |
-- |--------|-------|-------|
-- | (|)    | space | ( | ) |
-- | ( | )  | )     | (  )| |
local rule = require('nvim-autopairs.rule')
autopairs.add_rules {
    rule(' ', ' ')
        :with_pair(function (opts)
            local pair = opts.line:sub(opts.col - 1, opts.col)
            return vim.tbl_contains({ '()', '[]', '{}' }, pair)
        end),
    rule('( ', ' )')
        :with_pair(function() return false end)
        :with_move(function(opts)
            return opts.prev_char:match('.%)') ~= nil
        end)
        :use_key(')'),
    rule('{ ', ' }')
        :with_pair(function() return false end)
        :with_move(function(opts)
            return opts.prev_char:match('.%}') ~= nil
        end)
        :use_key('}'),
    rule('[ ', ' ]')
        :with_pair(function() return false end)
        :with_move(function(opts)
            return opts.prev_char:match('.%]') ~= nil
        end)
        :use_key(']')
}
