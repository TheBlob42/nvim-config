require('luasnip.session.snippet_collection').clear_snippets('clojure')

local luasnip = require('luasnip')
local fmt = require('luasnip.extras.fmt').fmt
local snippet = luasnip.snippet
local i = luasnip.insert_node

local clj_snippets = {
    snippet({ trig = 'defn', dscr = 'Define a function' },
        fmt('(defn {} [{}]{})',
        {
            i(1, 'fn'),
            i(2, 'args'),
            i(0, ''),
        })),
}

luasnip.add_snippets('clojure', clj_snippets)
