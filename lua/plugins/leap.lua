local leap = require('leap')

local function leap_in_current_win()
    leap.leap {
        target_windows = {
            vim.api.nvim_get_current_win()
        }
    }
end

vim.keymap.set('n', 's', leap_in_current_win, { desc = 'leap in the current window' })
vim.keymap.set('x', 's', leap_in_current_win, { desc = 'leap in the current window' })

vim.keymap.set('o', 'S', function()
    local _, row, col = unpack(vim.fn.getpos('.'))

    leap.leap {
        target_windows = {
            vim.api.nvim_get_current_win()
        },
        action = function(target)
            local t_row, t_col = unpack(target.pos)

            -- check in which direction the leap is executed
            -- and set the offset value accordingly to be inclusive
            local offset = 0
            if t_row > row or t_col > col then
                offset = 2
            end

            -- execute the jump manually with our custom offset value
            require('leap.jump')['jump-to!'](target.pos, {
                winid = target.wininfo.winid,
                mode = 'o',
                offset = offset,
            })
        end
    }
end, { desc = 'leap in the current window (inclusive)' })

vim.keymap.set('n', 'gs', function()
    local wins = vim.tbl_filter(function(win)
        local is_current = win == vim.api.nvim_get_current_win()
        local is_focusable = vim.api.nvim_win_get_config(win).focusable

        return not is_current and is_focusable
    end, vim.api.nvim_tabpage_list_wins(0))

    leap.leap { target_windows = wins }
end, { desc = 'leap into another window' })
