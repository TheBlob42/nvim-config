vim.keymap.set('n', '<F1>', '<CMD>setlocal spell!<CR>', { desc = 'toggle spell checking' })

local repeat_map = my.repeat_map
repeat_map('<Plug>SpellCheckNext', ']s')
repeat_map('<Plug>SpellCheckPrev', '[s')

vim.api.nvim_create_augroup('SpellChecking', {})
vim.api.nvim_create_autocmd('OptionSet', {
    callback = function()
        local option = vim.api.nvim_get_vvar('option_new')
        if option == '1' then
            print('on')
            vim.keymap.set('n', '<leader>cn', '<Plug>SpellCheckNext', { buffer = true, desc = 'next spelling error' })
            vim.keymap.set('n', '<leader>cN', '<Plug>SpellCheckPrev', { buffer = true, desc = 'prev spelling error' })
            vim.keymap.set('n', '<leader>cc', '<CMD>Telescope spell_suggest<CR>', { buffer = true, remap = true, desc = 'correct spelling error' })
        else
            -- use pcall if the mappings do not exist
            pcall(vim.keymap.del, 'n', '<leader>cn', { buffer = true })
            pcall(vim.keymap.del, 'n', '<leader>cN', { buffer = true })
            pcall(vim.keymap.del, 'n', '<leader>cc', { buffer = true })
        end
    end,
    pattern = 'spell',
    group = 'SpellChecking',
    desc = 'toggle spell checking mappings'
})
