-- only continue multiline comments
vim.opt_local.comments:remove('://')
vim.opt_local.comments:append('f://')

-- startup Java LSP server
require('lsp.servers.jdtls').start()
