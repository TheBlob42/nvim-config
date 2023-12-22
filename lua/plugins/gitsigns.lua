local gitsigns = require('gitsigns')

gitsigns.setup({
    current_line_blame_opts = {
        delay = 50,
    }
})

-- make jumps repeatable (with `vim-repeat`)
my.repeat_map('<Plug>GitSignsNextHunk', '<CMD>lua require("gitsigns").next_hunk()<CR>')
my.repeat_map('<Plug>GitSignsPrevHunk', '<CMD>lua require("gitsigns").prev_hunk()<CR>')

vim.keymap.set('n', '<leader>gp', gitsigns.preview_hunk, { desc = 'preview git hunk' })
vim.keymap.set('n', '<leader>gn', '<Plug>GitSignsNextHunk', { desc = 'next git hunk' })
vim.keymap.set('n', '<leader>gN', '<Plug>GitSignsPrevHunk', { desc = 'previous git hunk' })
vim.keymap.set('n', '<leader>gs', gitsigns.stage_hunk, { desc = 'stage git hunk' })
vim.keymap.set('n', '<leader>gr', gitsigns.reset_hunk, { desc = 'reset git hunk' })
vim.keymap.set('n', '<leader>gb', '<CMD>Gitsigns toggle_current_line_blame<CR>', { desc = 'git blame' })

-- make line blame message more visible
local blame_cmd = 'highlight! link GitSignsCurrentLineBlame Special'
vim.cmd(blame_cmd)
vim.api.nvim_create_autocmd('Colorscheme', {
    group = vim.api.nvim_create_augroup('GitsignsBlameLineColor', {}),
    pattern = '*',
    command = blame_cmd,
    desc = 'make gitsigns blame message more visible',
})
