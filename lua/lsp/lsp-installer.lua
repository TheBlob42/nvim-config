local status_ok, lsp_installer, servers, lspconfig = my.req('nvim-lsp-installer', 'nvim-lsp-installer.servers', 'lspconfig')
if not status_ok then
    return
end

lsp_installer.setup()

-- set lspconfig default server configuration
lspconfig.util.default_config = vim.tbl_extend(
    'force',
    lspconfig.util.default_config,
    {
        on_attach = require('lsp.handlers').on_attach,
        capabilities = require('lsp.handlers').make_capabilities(),
    }
)

-- setup all servers installed via 'nvim-lsp-installer'
for _, server in ipairs(servers.get_installed_servers()) do
    local config = {}
    local name = server.name

    if name == 'jdtls' then
        goto continue -- special handling for java (see `ftplugin/java.lua`)
    end

    if name == 'sumneko_lua' then
        config = require('lsp.servers.sumneko_lua').config
    end

    if name == 'tsserver' then
        config = require('lsp.servers.tsserver').config
    end

    if name == 'jsonls' then
        config = {
            filetypes = { 'json', 'jsonc' },
        }
    end

    lspconfig[name].setup(config)
    ::continue::
end

-- unfortunately there is currently no "hook" to directly setup a new server after it has been installed
-- this might get fixed in the future, for now we have to call ':lua require"lspconfig".<server>.setup()'
