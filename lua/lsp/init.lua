local utils = require('lsp.utils')

-- check for dynamic registered capabilities to ensure all mappings are set properly if the are changed
-- this is especially important for Java usage via JDTLS
-- should be fixed by: https://github.com/neovim/neovim/issues/24229
-- (see also https://github.com/neovim/neovim/pull/23681)
local orig_handler = vim.lsp.handlers['client/registerCapability']
vim.lsp.handlers['client/registerCapability'] = function(err, result, ctx)
    local orig_result = orig_handler(err, result, ctx)

    local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
    for bufnr, _ in pairs(client.attached_buffers) do
        utils.on_attach(client, bufnr)
    end

    return orig_result
end

-- configure installed LSP servers (only if installed via mason.nvim)
local default_config = {
    on_attach = utils.on_attach,
    capabilities = utils.capabilities,
}
local lspconfig = require('lspconfig')
require('mason').setup()
require('mason-lspconfig').setup()
require('mason-lspconfig').setup_handlers {
    function(server_name)
        lspconfig[server_name].setup(default_config)
    end,
    ['jdtls'] = function()
        -- do nothing (see 'ftplugin/java.lua')
    end,
}

require('lsp.dap') -- setup DAP as well
