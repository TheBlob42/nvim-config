require('tabline').setup()

vim.keymap.set('n', '<leader>tr', require('tabline.actions').set_tabname, { desc = 'rename tab' })

local function adapt_highlights()
    -- updating highlight groups is not possible with lua
    vim.api.nvim_set_hl(0, 'TabLineSel', { bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'TabLine', { bg = 'NONE', ctermbg = 'NONE' })
    vim.api.nvim_set_hl(0, 'TabLineSeparatorActive', { link = 'Special' })
    vim.api.nvim_set_hl(0, 'TabLineSeparatorInactive', { link = 'Comment' })
end

adapt_highlights()

vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('CustomTabline', {}),
    desc = 'adapt highlights for tabline.nvim',
    callback = adapt_highlights,
})

vim.api.nvim_create_user_command('SwitchTab', function()
    local tabs = vim.tbl_map(function(tabpage)
        -- check for custom tabpage title (fall back to active buffer name)
        local status, title = pcall(vim.api.nvim_tabpage_get_var, tabpage, 'TablineTitle')
        if not status then
            local win = vim.api.nvim_tabpage_get_win(tabpage)
            local buf = vim.fn.winbufnr(win)
            title = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':t')

            if title == '' then
                title = '[Empty]'
            end
        end

        return { tabpage, title }
    end, vim.api.nvim_list_tabpages())

    vim.ui.select(tabs, {
        prompt = 'Switch to another tab',
        format_item = function(tab)
            return tab[2]
        end
    }, function(tab)
        if tab then
            vim.api.nvim_set_current_tabpage(tab[1])
        end
    end)
end, {
    desc = 'Switch to a(nother) tab page',
    nargs = 0,
})
