local function win_width_resize(delta)
    vim.api.nvim_win_set_width(0, vim.api.nvim_win_get_width(0) + delta)

    -- special case for `drex.nvim`
    local status_drex, drex_drawer = pcall(require, 'drex.drawer')
    if status_drex then
        local win = drex_drawer.get_drawer_window()
        if win then
            drex_drawer.set_width(vim.api.nvim_win_get_width(win), false, false)
        end
    end

end

local function win_height_resize(delta)
    vim.api.nvim_win_set_height(0, vim.api.nvim_win_get_height(0) + delta)
end

vim.api.nvim_create_user_command('WinWidth', function(opts)
    win_width_resize(opts.args)
end, { nargs = 1, desc = 'alter window width' })

vim.api.nvim_create_user_command('WinHeight', function(opts)
    win_height_resize(opts.args)
end, { nargs = 1, desc = 'alter window height' })

local repeat_map = my.repeat_map
repeat_map('<Plug>IncWidth', '<CMD>WinWidth 5<CR>')
repeat_map('<Plug>DecWidth', '<CMD>WinWidth -5<CR>')
repeat_map('<Plug>IncHeight', '<CMD>WinHeight 5<CR>')
repeat_map('<Plug>DecHeight', '<CMD>WinHeight -5<CR>')

vim.keymap.set('n', '<leader>wL', '<Plug>IncWidth', { desc = 'increase window width' })
vim.keymap.set('n', '<leader>wH', '<Plug>DecWidth', { desc = 'decrease window width' })
vim.keymap.set('n', '<leader>wK', '<Plug>IncHeight', { desc = 'increase window height' })
vim.keymap.set('n', '<leader>wJ', '<Plug>DecHeight', { desc = 'decrease window height' })
