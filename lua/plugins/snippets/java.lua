require('luasnip.session.snippet_collection').clear_snippets('java')

local luasnip = require('luasnip')
local fmt = require('luasnip.extras.fmt').fmt
local snippet = luasnip.snippet
local t = luasnip.text_node
local i = luasnip.insert_node
local f = luasnip.function_node
local c = luasnip.choice_node

---Find the package path for the current java file
---This assumes your java code is located in a "src/.../java" folder structure
---@return string
local function java_package()
    local path = vim.fn.expand('%:h')
    local pkg_path = path:match("^.*src/.*/java/(.*)"):gsub("/", ".")
    return("package " .. pkg_path .. ";")
end

---Get the name of the current java class (based on the cursor position) via treesitter
---@return string?
local function get_class_name()
    local node = require('nvim-treesitter.ts_utils').get_node_at_cursor()

    while node do
        if node:type() == 'class_declaration' then
            break
        end
        node = node:parent()
    end

    if not node then
        return
    end

    return vim.treesitter.get_node_text(node:field('name')[1], 0)
end

return {
    snippet({ trig = 'pa', name = 'Package' }, {
        f(java_package),
    }),
    snippet({ trig = 'm', name = 'Method' }, {
        c(1, {
           i(nil, 'public'),
           i(nil, 'private'),
           i(nil, 'protected'),
        }),
        t(' '),
        i(2, 'static '),
        i(3, 'void'),
        t(' '),
        i(4, 'name'),
        t('('),
        i(5),
        t{ ') {', '\t' },
        i(0),
        t({ '', '}' }),
    }),
    snippet({ trig = 'c', name = 'Constructor' }, {
        i(1, 'public'),
        t(' '),
        f(get_class_name),
        t('('),
        i(2),
        t{ ') {', '\t' },
        i(0),
        t({ '', '}' }),
    }),
    snippet({ trig = 'jd', name = 'Javadoc' },
        fmt([[
            /**
             * {}
             */
        ]],
        {
            i(1, 'A short description')
        }
    )),
}
