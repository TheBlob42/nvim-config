local snippets = require('user.plugins.snippets')

snippets.set_generic_snippets {
    ['ts'] = function()
        return os.time() .. ''
    end,
    ['uuid'] = function()
        -- generates a random UUID v4
        -- https://gist.github.com/jrus/3197011
        math.randomseed(os.time())
        local random = math.random
        local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
        local uuid = template:gsub('[xy]', function(c)
            local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
            return string.format('%x', v)
        end)
        return uuid
    end,
}
