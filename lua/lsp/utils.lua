local M = {}

local highlight_group = vim.api.nvim_create_augroup('LspDocumentHighlight', {})

-- nvim-cmp supports additional capabilities
-- see: https://github.com/hrsh7th/cmp-nvim-lsp/issues/44#issuecomment-1591508900
M.capabilities = vim.tbl_deep_extend(
    'force',
    require('lspconfig').util.default_config,
    { capabilities = require('cmp_nvim_lsp').default_capabilities() })

---Function to set LSP specific keybindings based on the given server capabilities
---@param client table
---@param bufnr number
function M.on_attach(client, bufnr)
    -- some basics are set automatically since 0.8
    -- > jump to definition with `<C-]>` (tagfunc)
    -- > (range) formatting with `gq` (formatexpr)
    -- > basic auto completion (omnifunc)

    local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    -- key bindings without prefix
    map('n', 'K', vim.lsp.buf.hover, 'keyword')
    map('n', '<C-s>', vim.lsp.buf.signature_help, 'signature help')
    map('i', '<C-s>', vim.lsp.buf.signature_help, 'signature help')
    map('n', '<RightMouse>', '<LeftMouse><CMD>lua vim.lsp.buf.hover()<CR>', 'hover')
    map('n', '<2-LeftMouse>', vim.lsp.buf.definition, 'goto definition')

    -- general LSP leader keybindings
    if client.server_capabilities.renameProvider then
        map('n', '<localleader>r', vim.lsp.buf.rename, 'rename')
    end
    if client.server_capabilities.codeActionProvider then
        map('n', '<localleader>a', vim.lsp.buf.code_action, 'code action')
    end
    if client.server_capabilities.documentSymbolProvider then
        map('n', '<localleader>s', '<CMD>FzfLua lsp_document_symbols<CR>', 'document symbols')
    end
    if client.server_capabilities.workspaceSymbolProvider then
        map('n', '<localleader>S', '<CMD>FzfLua lsp_live_workspace_symbols<CR>', 'workspace symbols')
    end

    -- navigation 'g' bindings
    map('n', 'gd', '<C-]>', 'goto definition') -- map to 'gd' for convenience
    if client.server_capabilities.referencesProvider then
        map('n', 'gr', "<CMD>FzfLua lsp_references<CR>", 'goto references')
    end
    if client.server_capabilities.implementationProvider then
        map('n', 'gI', vim.lsp.buf.implementation, 'goto implementation')
    end
    if client.server_capabilities.declarationProvider then
        map('n', 'gD', vim.lsp.buf.declaration, 'goto declaration')
    end

    -- set autocommands conditional on server capabilities
    if client.server_capabilities.documentHighlightProvider then
        vim.api.nvim_clear_autocmds {
            group = highlight_group,
            buffer = bufnr,
        }
        vim.api.nvim_create_autocmd('CursorHold', {
            group = highlight_group,
            buffer = bufnr,
            callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd('CursorMoved', {
            group = highlight_group,
            buffer = bufnr,
            callback = vim.lsp.buf.clear_references,
        })
    end
end

return M
