local status_ok, autopairs, cmp = my.req('nvim-autopairs', 'cmp')
if not status_ok then
    return
end

autopairs.setup {
    -- don't add a pair if theres already a closing bracket in the same line
    enable_check_bracket_line = true
}

-- setup for `nvim-cmp`
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({ map_char = { tex = '' } }))

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
