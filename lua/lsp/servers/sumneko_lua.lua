return {
    config = require('lua-dev').setup {
        lspconfig = {
            on_attach = require('lsp.handlers').on_attach,
            capabilities = require('lsp.handlers').capabilities,
        }
    }
}
