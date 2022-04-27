local status_ok, autopairs, cmp, cmp_autopairs, rule = my.req(
    'nvim-autopairs',
    'cmp',
    'nvim-autopairs.completion.cmp',
    'nvim-autopairs.rule'
)
if not status_ok then
    return
end

autopairs.setup {
    -- don't add a pair if theres already a closing bracket in the same line
    enable_check_bracket_line = true
}

-- setup for `nvim-cmp`
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({ map_char = { tex = '' } }))

-- add spaces between parentheses
--
-- | Before | Input | After |
-- |--------|-------|-------|
-- | (|)    | space | ( | ) |
-- | ( | )  | )     | (  )| |
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
