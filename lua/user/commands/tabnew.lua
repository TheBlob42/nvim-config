-- create a new tabpage with the current buffer and switch to it
-- this also works if the current buffer does not visits a file
vim.api.nvim_create_user_command('TabNew', function()
    if vim.fn.expand('%') ~= '' then
        vim.cmd("tabnew %")
    else
        local old_buffer = vim.api.nvim_get_current_buf()

        -- calling 'tabnew' creates a new empty buffer, which we delete afterwards
        vim.cmd("tabnew")
        local new_buffer = vim.api.nvim_get_current_buf()

        vim.api.nvim_win_set_buf(0, old_buffer)
        vim.api.nvim_buf_delete(new_buffer, { force = true })
    end
end, { desc = 'create a new tabpage' })
