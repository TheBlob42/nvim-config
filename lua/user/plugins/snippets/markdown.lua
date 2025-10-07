local snippets = require('user.plugins.snippets')
local format = snippets.format

snippets.set_snippets('markdown', {
    ['b'] = '**$1**',
    ['i'] = '*$1*',
    ['l'] = '[$1]($2)',
    ['img'] = '![$1]($2)',
    ['c'] = '`$1`',
    ['cc'] = format [[
        ```$1
        $0
        ```
    ]],
    ['tbl(%d*),?(%d*)'] = function(_, cols, rows)
        cols = tonumber(cols ~= '' and cols or 1)
        rows = tonumber(rows ~= '' and rows or 1) + 2
        local tbl = ''
        local index = 1
        local add_row = function(row)
            tbl = tbl .. '|'
            for _ = 1, cols do
                if row == 2 then
                    tbl = tbl .. ' --- |'
                else
                    local placeholder = row == 1 and 'header' or 'column'
                    tbl = tbl .. ' ${' .. index .. ':' .. placeholder .. '} |'
                    index = index + 1
                end
            end

            if row ~= rows then
                tbl = tbl .. '\n'
            end
        end
        for i = 1, rows do
            add_row(i)
        end

        return tbl
    end,
})
