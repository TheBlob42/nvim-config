local status_ok, lsp_installer = my.req('nvim-lsp-installer')
if not status_ok then
    return
end

lsp_installer.setup()
local lspconfig = require('lspconfig')

lspconfig.sumneko_lua.setup(require('lsp.servers.sumneko_lua').config)

lspconfig.jsonls.setup(require('lsp.servers.jsonls').config)

lspconfig.tsserver.setup(require('lsp.servers.tsserver').config)

-- special handling for java (see `ftplugin/java.lua`)

-- lsp_installer.on_server_ready(function(server)
--     local config = {
--         on_attach = require('lsp.handlers').on_attach,
--         capabilities = require('lsp.handlers').make_capabilities(),
--     }

--     if server.name == 'jdtls' then
--         -- special handling for java (see 'ftplugin/java.lua')
--         return
--     end

--     if server.name == 'sumneko_lua' then
--         config = require('lsp.servers.sumneko_lua').config
--     end

--     if server.name == 'jsonls' then
--         config = require('lsp.servers.jsonls').config
--     end

--     if server.name == 'tsserver' then
--         config = require('lsp.servers.tsserver').config
--     end

--     server:setup(config)
-- end)
