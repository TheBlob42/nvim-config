-- open the link under the cursor with the default application (using `xdg-open`)
vim.api.nvim_create_user_command('XOpen', function()
    local link = vim.fn.expand('<cWORD>')
    -- perform some "cleanup" (e.g. link within parentheses)
    link = link:match('[^a-z]*([a-z]+://[^<>,;()]*)[<>,;()]*')
    link = vim.fn.shellescape(link, 1)

    -- NOTE: xdg-open is only available for Linux
    vim.cmd('silent !xdg-open ' .. link)
end, { desc =  'open the link under the cursor via xdg-open' })
