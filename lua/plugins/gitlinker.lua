require('gitlinker').setup {
    mappings = '<leader>gy',
    -- check for locally configured custom callback
    callbacks = vim.tbl_get(my.sys_local, 'git', 'gitlinker_callbacks') or {},
}

-- override keybindings to get descriptions
vim.keymap.set('n', '<leader>gy', function()
    require('gitlinker').get_buf_range_url('n')
end, { desc = 'copy git permalink' })

vim.keymap.set('v', '<leader>gy', function()
    require('gitlinker').get_buf_range_url('v')
end, { desc = 'copy git permalink' })
