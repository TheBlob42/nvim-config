local utils = require('lsp.utils')

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

-- check for dynamic registered capabilities to ensure all mappings are set properly
-- should be fixed by: https://github.com/neovim/neovim/issues/24229
-- (see also https://github.com/neovim/neovim/pull/23681)
local orig_handler = vim.lsp.handlers['client/registerCapability']
vim.lsp.handlers['client/registerCapability'] = function(err, result, ctx)
    local orig_result = orig_handler(err, result, ctx)

    local client = vim.lsp.get_client_by_id(ctx.client_id)
    for bufnr, _ in ipairs(client.attached_buffers) do
        utils.on_attach(client, bufnr)
    end

    return orig_result
end

-- configure installed LSP servers (only if installed via mason.nvim)
local lspconfig = require('lspconfig')
require('mason').setup()
require('mason-lspconfig').setup_handlers {
    function(server_name)
        local config = {
            on_attach = utils.on_attach,
            capabilities = utils.capabilities,
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
