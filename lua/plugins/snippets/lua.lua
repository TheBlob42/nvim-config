require('luasnip.session.snippet_collection').clear_snippets('lua')

local luasnip = require('luasnip')
local fmt = require('luasnip.extras.fmt').fmt
local snippet = luasnip.snippet
local t = luasnip.text_node
local i = luasnip.insert_node
local c = luasnip.choice_node
local sn = luasnip.snippet_node

local lua_snippets = {
    snippet({ trig = 'fn', name = 'Function', dscr = 'Insert a function' },
        fmt("function({}){}end",
        {
            i(1),
            c(2, {
                { t(' '), i(1), t(' ') },                 -- for inline functions
                { t({ '', '\t' }), i(1), t({ '', '' }) }, -- for proper line breaks
            })
        })),

    snippet({ trig = 'fnn', name = 'Named Function', dscr = 'Insert a named function' },
        fmt([[
            {}function {}({})
                {}
            end
        ]],
        {
            i(1, 'local '),
            i(2, 'name'),
            i(3),
            i(4),
        })),

    snippet({ trig = 'lv', name = 'Local Variable', dscr = 'Insert a local variable'},
        fmt('local {} = {}', { i(1, 'var'), i(2, 'value') })),

    snippet({ trig = 'r', name = 'Require' },
        fmt("require('{}')", i(1))),

    snippet({ trig = 'if', name = 'If Statement' },
        fmt([[
            if {} then
                {}
            end
        ]], { i(1, 'true'), i(2) })),

    snippet({ trig = 'ife', name = 'If-Else Statement' },
        fmt([[
            if {} then
                {}
            else
                {}
            end
        ]], { i(1, 'true'), i(2), i(3) })),

    snippet({ trig = 'for', name = 'For (Each) Loop' },
        fmt([[
            for {}, {} in {} do
                {}
            end
        ]], {
            i(1, 'index'),
            i(2, 'value'),
            c(3, {
                sn(nil, { t('pairs('), i(1), t(')') }),
                sn(nil, { t('ipairs('), i(1), t(')') }),
                i(nil),
            }),
            i(4),
        })
    ),
}

luasnip.add_snippets('lua', lua_snippets)
