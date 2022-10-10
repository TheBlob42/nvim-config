local ts_utils = require('nvim-lsp-ts-utils')

return {
    config = {
        init_options = ts_utils.init_options,
        preferences = {
            importModuleSpecifierPreference = "project-relative",
        },
        on_attach = function(client, bufnr)
            ts_utils.setup({})
            ts_utils.setup_client(client)

            vim.keymap.set('n', '<localleader>i', '<CMD>TSLspImportAll<CR>',  { buffer = bufnr, desc = 'import all' })
            vim.keymap.set('n', '<localleader>o', '<CMD>TSLspOrganize<CR>',   { buffer = bufnr, desc = 'organize imports' })
            vim.keymap.set('n', '<localleader>R', '<CMD>TSLspRenameFile<CR>', { buffer = bufnr, desc = 'rename file' })

            require('lsp.utils').on_attach(client, bufnr)
        end,
    }
}
