local status_ok, lsp_installer = my.req('nvim-lsp-installer')
if not status_ok then
    return
end

local defaults = {
    on_attach = require('lsp.handlers').on_attach,
    capabilities = require('lsp.handlers').make_capabilities(),
}

lsp_installer.on_server_ready(function(server)
    local config = defaults

    if server.name == 'jdtls' then
        -- special handling for java (see 'ftplugin/java.lua')
        return
    end

    if server.name == 'sumneko_lua' then
        config = require('lsp.servers.sumneko_lua').config
    end

    if server.name == 'jsonls' then
        config = require('lsp.servers.jsonls').config
    end

    if server.name == 'tsserver' then
        config = require('lsp.servers.tsserver').config
    end

    server:setup(config)
end)
