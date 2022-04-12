-- use as git commit message editor
if vim.fn.executable('nvr') then
    vim.env.GIT_EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
end

vim.keymap.set('n', '<leader>gg', function()
    -- to also make it work inside of non-file buffers (e.g. file manager)
    require('lazygit').lazygit(vim.fn.getcwd())
end, { desc = 'open lazygit'})
