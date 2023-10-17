-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- This file has to be loaded BEFORE the conjure plugin NOT afterwards
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

vim.g['conjure#filetypes'] = my.lisps
vim.g['conjure#filetype#fennel'] = 'conjure.client.fennel.stdio'

-- the log buffer contains non-valid clojure in the presented evaluation results
vim.api.nvim_create_autocmd('BufNewFile', {
    group = vim.api.nvim_create_augroup('ConjureLogDisableDiagnostic', {}),
    pattern = { 'conjure-log-*' },
    callback = function()
        vim.diagnostic.disable(0)
    end,
    desc = 'disable diagnostics for conjure log buffer',
})
