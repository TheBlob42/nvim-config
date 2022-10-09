local lspconfig = require('lspconfig')

require('mason').setup()
require('mason-lspconfig').setup()

require('mason-lspconfig').setup_handlers {
    function(server_name)
        local config = {
            on_attach = require('lsp.handlers').on_attach,
            capabilities = require('lsp.handlers').make_capabilities(),
        }
        lspconfig[server_name].setup(config)
    end,
    ['sumneko_lua'] = function()
        lspconfig['sumneko_lua'].setup(
            require('lsp.servers.sumneko_lua').config
        )
    end,
    ['tsserver'] = function()
        lspconfig['tsserver'].setup(
            require('lsp.servers.tsserver')
        )
    end,
    ['jdtls'] = function()
        -- do nothing (see 'ftplugin/java.lua')
    end,
}
