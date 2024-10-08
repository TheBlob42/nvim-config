-- this would is otherwise overridden by 'ft-markdown-plugin'
vim.opt_local.foldtext = ''

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

vim.keymap.set('n', '<TAB>', 'za', {
    silent = true,
    buffer = true,
    desc = 'toggle the fold under the cursor',
})
vim.keymap.set('n', '<S-TAB>', toggle_all_folds, {
    expr = true,
    buffer = true,
    desc = 'toggle all folds in the current buffer',
})

---Cycle the todo state of list elements between 'none', '[ ]' and '[X]'
local function cycle_todo_state()
    local row = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()
    local prefix, rest = line:match('^(%s*[-*]) (.*)$')

    if prefix and rest then
        local state, text = rest:match('^(%[.]) (.*)$')
        if state and text then
            if state == '[ ]' then
                state = '[x]'
            else
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

---Create a markdown link element from the currently selected text
---@param pre_select_cmd string? Selection command to execute beforehand if called from normal mode (e.g. 'viW', 'V' etc.)
---@return function rhs Function which can be used as key mapping
local function create_link(pre_select_cmd)
    pre_select_cmd = pre_select_cmd or ''
    return function()
        local zreg = vim.fn.getreg('z')
        vim.cmd(vim.api.nvim_replace_termcodes(':normal! ' .. pre_select_cmd .. '"zc[<C-r>z]()<Left>', true, false, true))
        vim.fn.setreg('z', zreg)
    end
end

vim.keymap.set('x', '<localleader>l', create_link(), { buffer = true, desc = 'create link from selection' })
vim.keymap.set('n', '<localleader>l', create_link('viW'), { buffer = true, desc = 'create link from WORD' })

---Paste image data directly from the system clipboard
---Create a new image file from the data using `xclip`
---Then insert an image link to this newly created file
---
---Inspired from `ekickx/clipboard-image.nvim`
---
---@param paste_before_cursor boolean Paste before (`P`) or after (`p`) the cursor (default)
---@return function
local function md_paste(paste_before_cursor)
    return function()
        -- only check for the `unnamed` and `unnamedplus` registers
        if vim.v.register == '*' or vim.v.register == '+' then
            local out = io.popen('xclip -selection clipboard -o -t TARGETS')
            assert(out)
            for line in out:lines() do
                if line == 'image/png' then
                    local img_path = string.format('%s/pasted-%s.png',
                    vim.fn.fnamemodify(vim.fn.expand('%'), ':p:h'),
                    os.date('%Y-%m-%d-%H-%M-%S'))

                    io.popen('xclip -selection clipboard -t image/png -o > "' .. img_path .. '"')

                    return string.format('%s![](%s)<ESC>%si',
                    (paste_before_cursor and 'i' or 'a'),
                    img_path,
                    string.rep('h', vim.str_utfindex(img_path) + 2))
                end
            end
        end

        return paste_before_cursor and 'P' or 'p'
    end
end

vim.keymap.set('n', 'p', md_paste(false), { buffer = true, expr = true, desc = 'Paste text or copied image' })
vim.keymap.set('n', 'P', md_paste(true),  { buffer = true, expr = true, desc = 'Paste text or copied image' })

-- needs `sed` and `column` (including the `-t` option) to be installed
vim.keymap.set('x', '<localleader>f', [[!sed "s/ *| */§| /g" | column -t -s "§" | sed "s/  |/ |/g" | sed "s/| $/|/g"<CR>]], { buffer = true, desc = 'Format table' })
