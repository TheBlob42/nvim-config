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

-- experimental mapping for now, lets see how (and if) this evolves
vim.g['conjure#mapping#prefix'] = ','

-- add custom prefix labels for which-key
vim.api.nvim_create_autocmd('FileType', {
    pattern = my.lisps,
    callback = function(opts)
        if vim.api.nvim_buf_is_loaded(opts.buf) then
            require('which-key').register({
                name = 'Conjure',
                ['c']  = { name = 'Connect' },
                ['e']  = { name = 'Evaluate' },
                ['ec'] = { name = 'Comment' },
                ['g']  = { name = 'Get' },
                ['l']  = { name = 'Logs' },
                ['r']  = { name = 'Refresh' },
                ['s']  = { name = 'Session' },
                ['t']  = { name = 'Tests' },
                ['v']  = { name = 'View' },
            }, {
                prefix = vim.g['conjure#mapping#prefix'],
                buffer = opts.buf
            })
        end
    end,
})
