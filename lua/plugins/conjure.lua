-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- This file has to be loaded BEFORE the conjure plugin NOT afterwards
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

vim.g['conjure#filetypes'] = my.lisps
vim.g['conjure#filetype#fennel'] = 'conjure.client.fennel.stdio'

-- experimental mapping for now, lets see how (and if) this evolves
vim.g['conjure#mapping#prefix'] = ','
vim.g['conjure#mapping#doc_word'] = { '<C-k>' } -- avoid conflict with LSP mapping

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
