return {
    config = require('lua-dev').setup {
        lspconfig = {
            on_attach = require('lsp.utils').on_attach,
            capabilities = require('lsp.utils').capabilities,
        }
    }
}
