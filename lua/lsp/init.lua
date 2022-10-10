require('lsp.dap')

-- update diagnostics in insert mode too
vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics,
    { update_in_insert = true }
)

-- window border for hover float
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
    vim.lsp.handlers.hover,
    { border = "rounded" }
)

-- configure installed LSP servers (only if installed via mason.nvim)
local lspconfig = require('lspconfig')
require('mason').setup()
require('mason-lspconfig').setup()
require('mason-lspconfig').setup_handlers {
    function(server_name)
        local config = {
            on_attach = require('lsp.handlers').on_attach,
            capabilities = require('lsp.handlers').capabilities,
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
