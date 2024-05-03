local luasnip = require('luasnip')

local map = vim.api.nvim_set_keymap
local expr_opts = { expr = true, silent = true }
local nor_opts  = { noremap = true, silent = true }

map('i', '<Tab>',   "luasnip#expand_or_locally_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>'", expr_opts)

map('i', '<S-Tab>', "<cmd>lua require('luasnip').jump(-1)<CR>", nor_opts)
map('s', '<Tab>',   "<cmd>lua require('luasnip').jump(1)<CR>",  nor_opts)
map('s', '<S-Tab>', "<cmd>lua require('luasnip').jump(-1)<CR>", nor_opts)

map('i', '<C-e>', "luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'", expr_opts)
map('s', '<C-e>', "luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'", expr_opts)

luasnip.config.setup {
    -- clear jump nodes on CursorHold after leaving a snippet
    region_check_events = "CursorHold"
}

require('plugins.snippets.clojure')
require('plugins.snippets.java')
require('plugins.snippets.lua')
require('plugins.snippets.markdown')
