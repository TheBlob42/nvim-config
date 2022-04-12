local status_ok, cmp_nvim_lsp = my.req('cmp_nvim_lsp')
if not status_ok then
    return
end

local M = {}

function M.on_attach(client, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

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
    if client.resolved_capabilities.rename then
        map('n', '<localleader>r', vim.lsp.buf.rename, 'rename')
    end
    if client.resolved_capabilities.code_action then
        map('n', '<localleader>a', vim.lsp.buf.code_action, 'code action')
    end
    if client.resolved_capabilities.document_symbol then
        map('n', '<localleader>s', '<CMD>Telescope lsp_document_symbols<CR>', 'document symbols')
    end
    if client.resolved_capabilities.workspace_symbol then
        map('n', '<localleader>S', '<CMD>Telescope lsp_dynamic_workspace_symbols<CR>', 'workspace symbols')
    end
    if client.resolved_capabilities.document_formatting then
        map('n', '<localleader>f', vim.lsp.buf.formatting, 'format buffer')
        vim.api.nvim_buf_set_option(bufnr, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')
    end

    -- navigation 'g' bindings
    if client.resolved_capabilities.goto_definition then
        map('n', 'gd', vim.lsp.buf.definition, 'goto definition')
        vim.api.nvim_buf_set_option(bufnr, 'tagfunc', 'v:lua.vim.lsp.tagfunc')
    end
    if client.resolved_capabilities.find_references then
        map('n', 'gr', "<CMD>Telescope lsp_references<CR>", 'goto references')
    end
    if client.resolved_capabilities.implementation then
        map('n', 'gI', vim.lsp.buf.implementation, 'goto implementation')
    end

    if client.resolved_capabilities.declaration then
        map('n', 'gD', vim.lsp.buf.declaration, 'goto declaration')
    end

    -- visual-mode bindings
    if client.resolved_capabilities.range_formatting then
        map('v', '<localleader>a', vim.lsp.buf.range_code_action, 'code action')
    end
    if client.resolved_capabilities.document_range_formatting then
        map('v', '<localleader>f', vim.lsp.buf.range_formatting, 'format selection')
    end

    -- set autocommands conditional on server capabilities
    if client.resolved_capabilities.document_highlight then
        vim.api.nvim_exec([[
            augroup lsp_document_highlight
                au! * <buffer>
                au CursorHold  <buffer> lua vim.lsp.buf.document_highlight()
                au CursorMoved <buffer> lua vim.lsp.buf.clear_references()
            augroup end
        ]], false)
    end
end

function M.make_capabilities()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.workspace.configuration = true
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities = cmp_nvim_lsp.update_capabilities(capabilities)

    return capabilities
end

return M
