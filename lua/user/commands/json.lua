-- try to format the current buffer as JSON
vim.api.nvim_create_user_command('JsonFormat', function()
    if vim.fn.executable('jq') == 0 then
        vim.api.nvim_echo({{ "'jq' was not found in PATH, install it in order to use this command!" , 'ErrorMsg'}}, false, {})
        return
    end

    -- check for JSON or scratch buffer
    local ft = vim.api.nvim_buf_get_option(0, 'filetype')
    if ft == '' or ft == 'json' then
        vim.api.nvim_buf_set_option(0, 'filetype', 'json')
        vim.api.nvim_command('%!jq .')
        return
    end

    print("Not a JSON buffer, please check 'filetype'!")
end, { desc = 'format json' })
