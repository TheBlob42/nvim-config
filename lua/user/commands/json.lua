-- try to format the current range (default: whole buffer) as JSON
vim.api.nvim_create_user_command('JsonFormat', function(args)
    if vim.fn.executable('jq') == 0 then
        vim.api.nvim_echo({{ "'jq' was not found in PATH, install it in order to use this command!" , 'ErrorMsg'}}, false, {})
        return
    end

    local first = args.line1
    local last = args.line2

    -- if the whole buffer is JSON we can set the appropriate filetype
    if first == 1 and last == vim.fn.line('$') then
        vim.api.nvim_set_option_value('filetype', 'json', { buf = 0 })
    end

    vim.cmd(string.format('%s,%s!jq .', first, last))
end, {
    desc = 'format json',
    range = '%',
})
