vim.o.complete = '.,w'
vim.o.completeopt = 'menuone,popup,fuzzy,noselect'
vim.o.wildmode = 'noselect:full'
vim.o.wildoptions = 'pum,tagfile,fuzzy'
vim.o.pumborder = 'single'

-- auto continue file completion on accept if possible (CTRL-X CTRL-F)
vim.api.nvim_create_autocmd('CompleteDone', {
    group = vim.api.nvim_create_augroup('FileCompletionDone', {}),
    pattern = '*',
    callback = function()
        if vim.v.event.complete_type == 'files' and vim.v.event.reason == 'accept' then
            local path = vim.fn.fnamemodify(vim.fn.expand(vim.v.completed_item.word), ':p')
            local is_directory = vim.uv.fs_lstat(path).type == 'directory'
            if is_directory then
                vim.schedule(function()
                    vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-x><C-f>', true, false, true), 'm')
                end)
            end
        end
    end,
})

vim.keymap.set('i', '<C-o>', '<C-x><C-o>', { desc = 'Shortcut for omnicompletion' })
vim.keymap.set('i', '<C-f>', '<C-x><C-f>', { desc = 'Shortcut for file/path completion' })

-- when the completion menu is visible and some entry there is selected <CR> should work as <C-Y>
-- should also integration with the nvim-autopairs plugin on <CR>
vim.keymap.set('i', '<CR>', function()
    local selected = vim.fn.complete_info({'selected'}).selected
    if selected > -1 then
        return vim.api.nvim_replace_termcodes('<C-Y>', true, false, true)
    end
    return require('nvim-autopairs').completion_confirm()
end, {
    expr = true,
    replace_keycodes = false, -- to make autopairs completion confirm work properly
    desc = '<CR> should work like <C-Y> when completion menu is visible'
})
