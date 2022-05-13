local status_ok, luasnip = my.req('luasnip')
if not status_ok then
    return
end

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

-- ~~~~~~~~~~~~~~~~~~~
-- ~ custom snippets ~
-- ~~~~~~~~~~~~~~~~~~~

luasnip.add_snippets('markdown', require('plugins.snippets.markdown'))
luasnip.add_snippets('java', require('plugins.snippets.java'))
luasnip.add_snippets('lua', require('plugins.snippets.lua'))

-- avoid duplicate & unwanted snippets by deleting snippet files from friendly snippet (but keep lazy loading functionality)
local repo_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/friendly-snippets/snippets/'
for _, ft in ipairs({ 'lua', 'markdown' }) do
    os.remove(repo_path .. ft .. '.json')
end

require("luasnip/loaders/from_vscode").lazy_load()
