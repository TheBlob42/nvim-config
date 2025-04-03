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
    local supports = function(method)
        return client.supports_method(method, { bufnr = bufnr })
    end
    local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    -- override default mappings with "upgraded" functions
    if supports('textDocument/documentSymbol') then
        map('n', 'gO', Snacks.picker.lsp_symbols, 'document symbols')
    end
    if supports('textDocument/references') then
        map('n', 'grr', function()
            Snacks.picker.lsp_references {
                jump = {
                    tagstack = true,
                    reuse_win = false,
                }
            }
        end, 'goto references')
    end

    -- additional mappings
    if supports('textDocument/declaration') then
        map('n', 'gD', vim.lsp.buf.declaration, 'goto declaration')
    end
    if supports('workspace/symbol') then
        map('n', 'g<C-o>', Snacks.picker.lsp_workspace_symbols, 'workspace symbols')
    end
    if supports('textDocument/definition') then
        map('n', 'gd', '<C-]>', 'goto definition')
    end

    -- highlighting autocommands
    if supports('textDocument/documentHighlight') then
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
