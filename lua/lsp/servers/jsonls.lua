return {
    config = {
        on_attach = require('lsp.handlers').on_attach,
        capabilities = require('lsp.handlers').make_capabilities(),
        filetypes = { 'json', 'jsonc' }
    }
}
