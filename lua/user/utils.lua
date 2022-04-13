---Simple Wrapper around `print(vim.inspect(x))`
function P(x)
    print(vim.inspect(x))
end

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
---@param plug string Name for the <Plug> mapping
---@param ... string All lines of the mapping
function my.repeat_map(plug, ...)
    if not my.lookup(packer_plugins, { 'vim-repeat' }) then
        print(debug.getinfo(2).source .. ' --> `vim-repeat` is not loaded!')
        return
    end

    local mappings = {...}
    vim.api.nvim_set_keymap(
        'n',
        plug,
        table.concat(mappings, '') .. ':call repeat#set("\\' .. plug .. '", v:count)<CR>',
        { noremap = true, silent = true }
    )
end

---Extract a value from a nested table structure
---If there is a `nil` somewhere in the table structure return `nil` (or optional `default` value)
---If `tbl` is nil or not a table return `nil`
---@param tbl table The table to search in
---@param keys list List of keys to look up
---@param default any? Default value which should be returned if nothing is found
---@return any
function my.lookup(tbl, keys, default)
    if not tbl or type(tbl) ~= 'table' then
        return nil
    end

    for _, key in ipairs(keys) do
        tbl = tbl[key]
        if not tbl then
            return default
        end
    end

    return tbl
end
