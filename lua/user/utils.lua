P = vim.pretty_print -- shortening for easier debugging

---Try to require all given LUA modules
---If at least one "require" fails log an appropriate error and return `false`
---If everything works out fine, return `true` and all required modules
---@param ... string All Lua modules to require
---@return boolean status
---@return any? modules
function my.req(...)
    local arg = {...}
    local result = { true }
    local errors = {}

    for _, name in ipairs(arg) do
        local status, module = pcall(require, name)
        if status then
            table.insert(result, module)
        else
            table.insert(errors, name)
        end
    end

    if #errors > 0 then
        print(debug.getinfo(2).source .. ' --> Could not load: "' .. table.concat(errors, '", "') .. '"')
        return false
    end

    return unpack(result)
end

---Create a repeatable <Plug> mapping via `vim-repeat`
---@param plug string Name for the <Plug> mapping. Needs to start with "<Plug>"
---@param rhs string|function Either a mapping string or a function that should be executed
function my.repeat_map(plug, rhs)
    if not vim.tbl_get(packer_plugins, 'vim-repeat') then
        print(debug.getinfo(2).source .. ' --> `vim-repeat` is not loaded!')
        return
    end

    if plug:sub(0, 6) ~= '<Plug>' then
        vim.api.nvim_echo({{ 'Invalid <Plug> mapping: `plug` needs to start with "<Plug>"!', 'WarningMsg' }}, true, {})
        return
    end

    local command
    if type(rhs) == 'function' then
        command = function()
            rhs()
            vim.fn['repeat#set'](vim.api.nvim_replace_termcodes(plug, true, false, true), vim.v.count)
        end
    elseif type(rhs) == 'string' then
        command = rhs .. ':call repeat#set("\\' .. plug .. '", v:count)<CR>'
    else
        vim.api.nvim_echo({{ 'Wrong argument type: `rhs` needs to be a string or a function!', 'WarningMsg' }}, true, {})
        return
    end

    vim.keymap.set('n', plug, command, { silent = true })
end
