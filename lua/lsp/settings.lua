-- define diagnostic icons and colors
vim.fn.sign_define("DiagnosticSignError", {
    text = "",
    texthl = "DiagnosticError",
    numhl = "DiagnosticError",
})
vim.fn.sign_define("DiagnosticSignWarn", {
    text = "",
    texthl = "DiagnosticWarn",
    numhl = "DiagnosticWarn",
})
vim.fn.sign_define("DiagnosticSignHint", {
    text = "",
    texthl = "DiagnosticHint",
    numhl = "DiagnosticHint",
})
vim.fn.sign_define("DiagnosticSignInfo", {
    text = "",
    texthl = "DiagnosticInformation",
    numhl = "DiagnosticInformation",
})

-- update diagnostics in insert mode too
vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics,
    { update_in_insert = true }
)

-- window border for hover float
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
    vim.lsp.handlers.hover,
    { border = "rounded" }
)
