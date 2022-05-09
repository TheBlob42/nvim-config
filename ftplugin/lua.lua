-- only continue multiline comments
vim.opt_local.comments:remove(':--')
vim.opt_local.comments:append('f:--')

-- easily reload the current lua file
vim.api.nvim_buf_create_user_command(0, 'LuaReload', function(_)
    local file = vim.fn.expand('%')
    if not file then
        vim.api.nvim_echo({ 'Only works inside a file!', 'WarningMsg' }, false, {})
        return
    end

    local lua_script = string.match(vim.fn.expand('%'), '.*lua/(.*).lua')
    if lua_script then
        lua_script = lua_script:gsub('/', '.')
        package.loaded[lua_script] = nil
        require(lua_script)
        return
    end

    vim.cmd('luafile ' .. file)
end, { desc = 'reload/resource the current Lua file' })

vim.keymap.set('n', '<localleader>R', '<CMD>LuaReload<CR>', { buffer = true, desc = 'reload lua' })
