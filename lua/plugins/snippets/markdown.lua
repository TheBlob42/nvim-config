local luasnip = require('luasnip')
local fmt = require('luasnip.extras.fmt').fmt
local snippet = luasnip.snippet
local sn = luasnip.snippet_node
local t = luasnip.text_node
local i = luasnip.insert_node
local d = luasnip.dynamic_node

return {
    snippet({ trig = 'b', name = 'Bold' },
        fmt('**{}**', i(1))),

    snippet({ trig = 'i', name = 'Italic' },
        fmt('*{}*', i(1))),

    snippet({ trig = 'bi', name = 'Bold & Italic' },
        fmt('***{}***', i(1))),

    snippet({ trig = 'link', name = 'Link' },
        fmt('[{}]({})', { i(1), i(2) })),

    snippet({ trig = 'img', name = 'Image' },
        fmt('![{}]({})', { i(1), i(2) })),

    snippet({ trig = 'meta', name = 'Meta tag' },
        fmt('<meta name="{}" content="{}">', { i(1), i(2) })),

    snippet({ trig = 'code', name = 'Codeblock' },
        fmt([[
            ```{}
            {}
            ```
        ]], { i(1), i(2) })),

    snippet({
        trig = "tbl(%d?)(%d?)",
        regTrig = true,
        name = 'Table',
        dscr = 'Insert table with X columns and Y rows. First row is the heading.',
        docstring = table.concat({
            '| Heading 1 | ... | Heading n |',
            '| ---       | --- | ---       |',
            '| Item 1    | ... | Item n    |',
        }, '\n'),
    },

    {
        d(1, function(_, parent)
            local cols = tonumber(parent.snippet.captures[1])
            local rows = tonumber(parent.snippet.captures[2])

            if not cols or cols < 1 then
                cols = 1
            end
            if not rows or rows < 3 then
                rows = 3
            end

            local nodes = {}
            local index = 1

            for row = 1, rows do
                table.insert(nodes, t('|'))
                for c = 1, cols do
                    if row == 2 then
                        table.insert(nodes, t(' --- |'))
                    else
                        table.insert(nodes, t(' '))
                        table.insert(nodes, i(index, 'Column '..c))
                        table.insert(nodes, t(' |'))
                        index = index + 1
                    end
                end
                table.insert(nodes, t({ '', '' }))
            end

            return sn(nil, nodes)
        end, {})
    }),
}
