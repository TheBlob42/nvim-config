local status_ok, tabline, actions, highlights = my.req('tabline', 'tabline.actions', 'tabline.highlights')
if not status_ok then
    return
end

tabline.setup()

vim.keymap.set('n', '<leader>tr', actions.set_tabname, { desc = 'rename tab' })

local function reset_highlights()
    -- reset background colors
    highlights.c.active_bg = highlights.get_color('TabLineSel', 'bg')
    highlights.c.inactive_bg = highlights.get_color('TabLine', 'bg')

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
