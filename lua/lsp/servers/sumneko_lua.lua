return {
    config = require('lua-dev').setup {
        lspconfig = {
            on_attach = require('lsp.utils').on_attach,
            capabilities = require('lsp.utils').capabilities,
            settings = {
                Lua = {
                    workspace = {
                        -- https://github.com/neovim/nvim-lspconfig/issues/1700#issuecomment-1033127328
                        checkThirdParty = false,
                    }
                }
            }
        }
    }
}
