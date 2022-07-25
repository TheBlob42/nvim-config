local status_ok, gitlinker = my.req('gitlinker')
if not status_ok then
    return
end

local custom_callbacks = my.lookup(my.sys_local, { 'git', 'gitlinker_callbacks' }, {})

gitlinker.setup {
    mappings = '<leader>gy',
    callbacks = custom_callbacks,
}

-- override keybindings to get descriptions
vim.keymap.set('n', '<leader>gy', function()
    require('gitlinker').get_buf_range_url('n')
end, { desc = 'copy git permalink' })

vim.keymap.set('v', '<leader>gy', function()
    require('gitlinker').get_buf_range_url('v')
end, { desc = 'copy git permalink' })
