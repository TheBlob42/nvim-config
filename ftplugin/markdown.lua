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
