-- configuration file for plugins which should be lazy loaded but need configuration beforehand
-- for example: setting variables, defining keybindings, etc.

-- ~~~~~~~~
-- GITBLAME
-- ~~~~~~~~

vim.g.gitblame_enabled = 0 -- disable by default
vim.keymap.set('n', '<leader>gb', '<CMD>GitBlameToggle<CR>', { desc = 'git blame' })

-- ~~~~~~~
-- LAZYGIT
-- ~~~~~~~

if vim.fn.executable('nvr') then
    -- use as git commit message editor
    vim.env.GIT_EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
end

vim.keymap.set('n', '<leader>gg', function()
    -- to also make it work inside of non-file buffers (e.g. file manager)
    require('lazygit').lazygit(vim.fn.getcwd())
end, { desc = 'open lazygit'})

-- ~~~~~~~~~
-- GITLINKER
-- ~~~~~~~~~

vim.keymap.set('n', '<leader>gy', function()
    require('gitlinker').get_buf_range_url('n')
end, { desc = 'copy git permalink' })

vim.keymap.set('v', '<leader>gy', function()
    require('gitlinker').get_buf_range_url('v')
end, { desc = 'copy git permalink' })

-- ~~~~~~~
-- CONJURE
-- ~~~~~~~

vim.g['conjure#filetypes'] = my.lisps
vim.g['conjure#filetype#fennel'] = 'conjure.client.fennel.stdio'

-- ~~~~~~~~
-- PARINFER
-- ~~~~~~~~

vim.g.parinfer_filetypes = my.lisps

-- ~~~~~~~~~
-- BUFDELETE
-- ~~~~~~~~~

vim.keymap.set('n', '<leader>bd', '<CMD>Bdelete<CR>', { desc = 'delete buffer' })
vim.keymap.set('n', '<leader>bD', '<CMD>Bdelete!<CR>', { desc = 'force delete buffer' })

-- ~~~~~~~~~~
-- EASY ALIGN
-- ~~~~~~~~~~

vim.keymap.set('x', 'ga', '<Plug>(EasyAlign)', { desc = 'easy align' })
vim.keymap.set('n', 'ga', '<Plug>(EasyAlign)', { desc = 'easy align' })

-- ~~~~~~~~
-- FLOATERM
-- ~~~~~~~~

-- configuration for the floating terminal window
vim.g.floaterm_width      = 0.75
vim.g.floaterm_height     = 0.75
vim.g.floaterm_autoinsert = false

vim.keymap.set('n', "<leader>'", '<CMD>FloatermToggle<CR>', { desc = 'toggle terminal' })

-- ~~~~~~~~
-- SUDA.VIM
-- ~~~~~~~~

vim.keymap.set('n', '<leader>fer', '<CMD>SudaRead<CR>', { desc = 'sudo read' })
vim.keymap.set('n', '<leader>few', '<CMD>SudaWrite<CR>', { desc = 'sudo write' })

-- ~~~~~~~~
-- UNDOTREE
-- ~~~~~~~~

vim.g.undotree_WindowLayout = 4
vim.g.undotree_SetFocusWhenToggle = 1

vim.keymap.set('n', '<leader>U', '<CMD>UndotreeToggle<CR>', { desc = 'undo tree' })
