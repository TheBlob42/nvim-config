-- close ALL floating windows
vim.api.nvim_create_user_command('CloseFloats', function()
    for _, winnr in pairs(vim.api.nvim_list_wins()) do
        local config = vim.api.nvim_win_get_config(winnr)
        if config.relative ~= "" then
            vim.api.nvim_win_close(winnr, true)
        end
    end
end, { desc = 'close all floating windows' })
