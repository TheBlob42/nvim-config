---Check if there are any closed folds. If so unfold everything, else collapse everything
---@return string Either 'zR' or 'zM'. Use this as an expression mapping
local function toggle_all_folds()
    local any_folds = false
    for line=1,vim.fn.line('$') do
        if vim.fn.foldclosed(line) > -1 then
            any_folds = true
            break
        end
    end

    if any_folds then
        return "zR"
    else
        return "zM"
    end
end

vim.keymap.set('n', '<TAB>', 'za', { silent = true, buffer = true})
vim.keymap.set('n', '<S-TAB>', toggle_all_folds, { expr = true, buffer = true })

---Cycle the todo state of list elements between 'none', '[ ]', '[X]' and '[-]'
local function cycle_todo_state()
    local row = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()
    local prefix, rest = line:match('^(%s*%-) (.*)$')

    if prefix and rest then
        local state, text = rest:match('^(%[.]) (.*)$')
        if state and text then
            if state == '[ ]' then
                state = '[X]'
            elseif state == '[X]' then
                state = '[-]'
            elseif state == '[-]' then
                vim.api.nvim_buf_set_lines(0, row - 1, row, false, { prefix .. ' ' .. text })
                return
            end
        else
            state = '[ ]'
            text = rest
        end
        vim.api.nvim_buf_set_lines(0, row - 1, row, false, { prefix..' '..state..' '..text })
    end
end

my.repeat_map('<Plug>MarkdownTodoCycle', cycle_todo_state)
vim.keymap.set('n', '<localleader>t', '<Plug>MarkdownTodoCycle', { buffer = true, desc = 'cycle todo state' })
