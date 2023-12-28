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

-- window border for the LSP info float
require('lspconfig.ui.windows').default_options.border = 'single'

-- check for dynamic registered capabilities to ensure all mappings are set properly
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
require('mason-lspconfig').setup({})
require('mason-lspconfig').setup_handlers {
    function(server_name)
        lspconfig[server_name].setup(default_config)
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
    ['clojure_lsp'] = function()
        local config = vim.tbl_extend('force', default_config, {
            --[[
                conjure log files created at `pwd` might spawn additional LSPs that will be picked up by other buffer
                even though there might be a more specific root path available (e.g. in "multi projects" or "mono-repositories")
                also this avoids diagnostics in the log buffer which contains non-valid clojure code (e.g. results)
            --]]
            root_dir = function(fname, _)
                if not fname:find('conjure%-log%-') then
                    return lspconfig.util.root_pattern("project.clj", "deps.edn", "build.boot", "shadow-cljs.edn", ".git", "bb.edn")(fname)
                end
            end,
        })
        lspconfig['clojure_lsp'].setup(config)
    end,
    ['jdtls'] = function()
        -- do nothing (see 'ftplugin/java.lua')
    end,
}

require('lsp.dap') -- setup DAP as well
