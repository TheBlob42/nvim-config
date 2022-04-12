local status_ok, tabline, actions = my.req('tabline', 'tabline.actions')
if not status_ok then
    return
end

tabline.setup()

vim.keymap.set('n', '<leader>tr', actions.set_tabname, { desc = 'rename tab' })

local function reset_highlights()
    vim.api.nvim_set_hl(0, 'TabLineSel', { link = 'Special' })
    vim.api.nvim_set_hl(0, 'TabLineIconActive', { link = 'Special' })
    vim.api.nvim_set_hl(0, 'TabLineIconInactive', { link = 'Normal' })
    vim.api.nvim_set_hl(0, 'TabLineSeparatorActive', { link = 'Special' })
    vim.api.nvim_set_hl(0, 'TabLineSeparatorInactive', { link = 'Comment' })
    vim.api.nvim_set_hl(0, 'TabLineModifiedSeparatorActive', { link = 'Special' })
    vim.api.nvim_set_hl(0, 'TabLineModifiedSeparatorInactive', { link = 'Comment' })
end

reset_highlights()

vim.api.nvim_create_augroup('CustomTabline', {})
vim.api.nvim_create_autocmd('ColorScheme', {
    group = 'CustomTabline',
    desc = 'adapt highlights for tabline.nvim',
    callback = reset_highlights,
})
