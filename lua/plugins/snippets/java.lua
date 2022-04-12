local luasnip = require('luasnip')
local snippet = luasnip.snippet
local sn = luasnip.snippet_node
local t = luasnip.text_node
local i = luasnip.insert_node
local f = luasnip.function_node
local c = luasnip.choice_node
local d = luasnip.dynamic_node

local function java_package()
    local path = vim.fn.expand('%:h')
    local pkg_path = path:match("^.*src/main/java/(.*)"):gsub("/", ".")
    return("package " .. pkg_path .. ";")
end

local function java_doc(args)
    local nodes = {
        t({ '/**', ' * ' }),
        i(1, 'A short description'),
        t({ '', '' }),
    }
    local insert_index = 2

    local return_type = args[1][1]
    local raw_parameters = args[2][1]

    if raw_parameters ~= '' then
        local parameters = vim.split(raw_parameters, ',')
        for _, param in ipairs(parameters) do
            local name = param:match('%S+ (%w+).*')
            table.insert(nodes, t(' * @param ' .. name .. ' '))
            table.insert(nodes, i(insert_index))
            table.insert(nodes, t({ '', '' }))
            insert_index = insert_index + 1
        end
    end

    if return_type ~= 'void' then
        table.insert(nodes, t(' * @return '))
        table.insert(nodes, i(insert_index))
        table.insert(nodes, t({ '', '' }))
        insert_index = insert_index + 1
    end

    table.insert(nodes, t({ ' */', '' }))
    return sn(nil, nodes)
end

return {
    snippet({ trig = 'pa', name = 'Package' }, {
        f(java_package),
    }),
    snippet({ trig = 'm', name = 'Method' }, {
        d(5, java_doc, { 2, 4 }),
        c(1, {
            i(nil),
            t('public'),
            t('private'),
            t('protected'),
        }),
        t(' '),
        i(2, 'void'),
        t(' '),
        i(3, 'name'),
        t('('),
        i(4),
        t{ ') {', '\t' },
        i(0),
        t({ '', '}' }),
    })
}
