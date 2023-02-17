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
            on_attach = require('lsp.utils').on_attach,
            capabilities = require('lsp.utils').capabilities,
        }
        lspconfig[server_name].setup(config)
    end,
    ['lua_ls'] = function()
        require('neodev').setup() -- needs to be before lspconfig
        lspconfig['lua_ls'].setup(
            require('lsp.servers.lua_ls')
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

require('lsp.dap') -- setup DAP as well
