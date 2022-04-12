local status_ok, lua_dev = my.req('lua-dev')
if not status_ok then
    return
end

return {
    config = lua_dev.setup {
        lspconfig = {
            on_attach = require('lsp.handlers').on_attach,
            capabilities = require('lsp.handlers').make_capabilities(),
        }
    }
}
