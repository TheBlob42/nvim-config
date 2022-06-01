local status_ok, tabline, actions = my.req('tabline', 'tabline.actions')
if not status_ok then
    return
end

tabline.setup()

vim.keymap.set('n', '<leader>tr', actions.set_tabname, { desc = 'rename tab' })

local function adapt_highlights()
    -- updating highlight groups is not possible with lua
    vim.cmd('hi TabLineSel guibg=NONE')
    vim.cmd('hi TabLine guibg=NONE ctermbg=NONE')

    vim.api.nvim_set_hl(0, 'TabLineSeparatorActive', { link = 'Special' })
    vim.api.nvim_set_hl(0, 'TabLineSeparatorInactive', { link = 'Comment' })
end

adapt_highlights()

vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('CustomTabline', {}),
    desc = 'adapt highlights for tabline.nvim',
    callback = adapt_highlights,
})
