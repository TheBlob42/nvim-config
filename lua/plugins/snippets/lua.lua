local luasnip = require('luasnip')
local fmt = require('luasnip.extras.fmt').fmt
local snippet = luasnip.snippet
local t = luasnip.text_node
local i = luasnip.insert_node
local c = luasnip.choice_node

return {
    snippet({ trig = 'fn', name = 'Function' },
        fmt( "function({}) {} end", { i(1), i(2) })),

    snippet({ trig = 'lfn', name = 'Local Function', dscr = 'Insert a local function' },
        fmt([[
            local function {}({})
                {}
            end
        ]],
        { i(1, 'fn'), i(2), i(3) })),

    snippet({ trig = 'lv', name = 'Local Variable', dscr = 'Insert a local variable'},
        fmt( 'local {} = {}', { i(1, 'var'), i(2, 'value') })),

    snippet({ trig = 'r', name = 'Require' },
        fmt( "require('{}')", i(1))),

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

    snippet({ trig = 'while', name = 'While Loop' },
        fmt([[
            while {} do
                {}
            end
        ]], { i(1, 'true'), i(2) })),

    snippet({ trig = 'for', name = 'For Loop' },
        fmt([[
            for {}={},{} do
                {}
            end
        ]], {
            i(1, 'i'),
            i(2, '10'),
            i(3, '1'),
            i(4),
        })
    ),

    snippet({ trig = 'fore', name = 'For Each Loop' },
        fmt([[
            for {}, {} in {}pairs({}) do
                {}
            end
        ]], {
            i(1, 'index'),
            i(2, 'value'),
            c(3, {
               t(''),
               t('i'),
            }),
            i(4, 'table'),
            i(5),
        })
    ),
}
