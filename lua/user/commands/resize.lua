---Check if `win` has no other windows on its right side
---@param win number The window id or 0 for the current window
---@return boolean
local function no_right_neighbors(win)
    local vim_width = vim.opt.columns:get()
    local x = vim.api.nvim_win_get_position(win)[2]
    return vim_width == (x + vim.api.nvim_win_get_width(win))
end

---Check if `win` has no other windows below it
---@param win number The window id or 0 for the current window
---@return boolean
local function no_bottom_neighbors(win)
    local vim_height = vim.opt.lines:get()
    local y = vim.api.nvim_win_get_position(win)[1]
    -- additional '+ 1' to compensate for the statusline
    return vim_height == (y + vim.api.nvim_win_get_height(win) + 1 + vim.opt.cmdheight:get())
end

---Adopt the width of `win` by `delta`
---Also checks for the DREX drawer and adopts its width accordingly
---@param win number The window id or 0 for the current window
---@param delta number The width delta which should be applied
local function set_width(win, delta)
    vim.api.nvim_win_set_width(win, vim.api.nvim_win_get_width(win) + delta)

    local status_drex, drex_drawer = pcall(require, 'drex.drawer')
    if status_drex then
        local drawer_win = drex_drawer.get_drawer_window()
        if drawer_win then
            drex_drawer.set_width(vim.api.nvim_win_get_width(drawer_win), false, false)
        end
    end
end

vim.api.nvim_create_user_command('WinResizeRight', function(opts)
    local delta = no_right_neighbors(0) and -opts.args or opts.args
    set_width(0, delta)
end, { nargs = 1, desc = 'resize window towards the right' })

vim.api.nvim_create_user_command('WinResizeLeft', function(opts)
    local delta = no_right_neighbors(0) and opts.args or -opts.args
    set_width(0, delta)
end, { nargs = 1, desc = 'resize window to towards the left' })

vim.api.nvim_create_user_command('WinResizeUp', function(opts)
    local delta = no_bottom_neighbors(0) and opts.args or -opts.args
    vim.api.nvim_win_set_height(0, vim.api.nvim_win_get_height(0) + delta)
end, { nargs = 1, desc = 'resize window towards the top' })

vim.api.nvim_create_user_command('WinResizeDown', function(opts)
    local delta
    if no_bottom_neighbors(0) then
        -- when the window spans the whole height abort
        -- otherwise we would increase the height of the cmdline
        if vim.api.nvim_win_get_position(0)[1] < 2 then -- including tabline
            return
        end
        delta = -opts.args
    else
        delta = opts.args
    end
    vim.api.nvim_win_set_height(0, vim.api.nvim_win_get_height(0) + delta)
end, { nargs = 1, desc = 'resize window towards the bottom' })

-- make repeatable commands
my.repeat_map('<Plug>WinResizeRight', '<CMD>WinResizeRight 5<CR>')
my.repeat_map('<Plug>WinResizeLeft',  '<CMD>WinResizeLeft 5<CR>')
my.repeat_map('<Plug>WinResizeUp',    '<CMD>WinResizeUp 5<CR>')
my.repeat_map('<Plug>WinResizeDown',  '<CMD>WinResizeDown 5<CR>')
