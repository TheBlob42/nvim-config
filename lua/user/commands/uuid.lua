-- generate a new UUID
-- https://gist.github.com/jrus/3197011
local function gen_uuid()
    math.randomseed(os.time())
    local random = math.random
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return template:gsub('[xy]', function(c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

vim.api.nvim_create_user_command('InsertUUID', function()
    local uuid = gen_uuid()
    vim.cmd('normal! a' .. uuid)
end, { desc = 'insert a newly generated uuid' })
