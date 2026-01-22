-- remove 't' to avoid auto wrapping code
vim.opt_local.formatoptions:remove('t')

vim.bo.comments = 'n:;'
vim.bo.commentstring = '; %s'

vim.bo.tabstop = 2
vim.bo.shiftwidth = 2
