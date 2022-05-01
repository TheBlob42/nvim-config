-- GITBLAME

vim.g.gitblame_enabled = 0 -- disable by default
vim.keymap.set('n', '<leader>gb', '<CMD>GitBlameToggle<CR>', { desc = 'git blame' })

-- LAZYGIT

if vim.fn.executable('nvr') then
    -- use as git commit message editor
    vim.env.GIT_EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
end

vim.keymap.set('n', '<leader>gg', function()
    -- to also make it work inside of non-file buffers (e.g. file manager)
    require('lazygit').lazygit(vim.fn.getcwd())
end, { desc = 'open lazygit'})
