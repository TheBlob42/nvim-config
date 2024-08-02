local M = {}

local highlight_group = vim.api.nvim_create_augroup('LspDocumentHighlight', {})

-- nvim-cmp supports additional capabilities
-- see: https://github.com/hrsh7th/cmp-nvim-lsp/issues/44#issuecomment-1591508900
M.capabilities = vim.tbl_deep_extend(
    'force',
    require('lspconfig').util.default_config,
    { capabilities = require('cmp_nvim_lsp').default_capabilities() })

---Function to set LSP specific keybindings based on the given server capabilities
---Some basic keybindings are set by default (`lsp-defaults`) and are not repeated here
---@param client table
---@param bufnr number
function M.on_attach(client, bufnr)
    local fzf = require('fzf-lua')
    local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    -- "generic" keybindings
    if client.supports_method('textDocument/hover', { bufnr = bufnr }) then
        map('n', '<RightMouse>', vim.lsp.buf.hover, 'hover')
    end
    if client.supports_method('textDocument/signatureHelp', { bufnr = bufnr }) then
        map('n', '<C-s>', vim.lsp.buf.signature_help, 'signature help')
        map('i', '<C-s>', vim.lsp.buf.signature_help, 'signature help')
    end

    -- localleader keybindings
    if client.supports_method('textDocument/rename', { bufnr = bufnr }) then
        map('n', '<localleader>r', vim.lsp.buf.rename, 'rename')
    end
    if client.supports_method('textDocument/codeAction', { bufnr = bufnr }) then
        map('n', '<localleader>a', vim.lsp.buf.code_action, 'code action')
    end
    if client.supports_method('textDocument/documentSymbol', { bufnr = bufnr }) then
        map('n', '<localleader>s', fzf.lsp_document_symbols, 'document symbols')
    end
    if client.supports_method('workspace/symbol', { bufnr = bufnr }) then
        map('n', '<localleader>S', fzf.lsp_live_workspace_symbols, 'workspace symbols')
    end

    -- navigational keybindings ('g')
    if client.supports_method('textDocument/definition', { bufnr = bufnr }) then
        map('n', 'gd', '<C-]>', 'goto definition') -- map to 'gd' for convenience
        map('n', '<2-LeftMouse>', vim.lsp.buf.definition, 'goto definition')
    end
    if client.supports_method('textDocument/references', { bufnr = bufnr }) then
        map('n', 'gr', function()
            fzf.lsp_references {
                ignore_current_line = true,
                jump_to_single_result = true,
            }
        end, 'goto references')
    end
    if client.supports_method('textDocument/implementation', { bufnr = bufnr }) then
        map('n', 'gI', vim.lsp.buf.implementation, 'goto implementation')
    end
    if client.supports_method('textDocument/declaration', { bufnr = bufnr }) then
        map('n', 'gD', vim.lsp.buf.declaration, 'goto declaration')
    end

    -- highlighting autocommands
    if client.supports_method('textDocument/documentHighlight', { bufnr = bufnr }) then
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
