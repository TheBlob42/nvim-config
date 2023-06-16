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

-- ~~~~~~~~~~~~~~~~~~~
-- ~ custom snippets ~
-- ~~~~~~~~~~~~~~~~~~~

luasnip.add_snippets('markdown', require('plugins.snippets.markdown'))
luasnip.add_snippets('java', require('plugins.snippets.java'))
luasnip.add_snippets('lua', require('plugins.snippets.lua'))

-- avoid duplicate & unwanted snippets by deleting snippet files from friendly snippet (but keep lazy loading functionality)
local repo_path = vim.fs.joinpath(vim.fn.stdpath('data'), 'lazy', 'friendly-snippets', 'snippets')
for _, ft in ipairs({ 'lua', 'markdown' }) do
    local ft_path = vim.fs.joinpath(repo_path, ft)
    os.remove(ft_path .. '.json')

    -- delete snippet files in subfolders
    for file in vim.fs.dir(ft_path) do
        os.remove(vim.fs.joinpath(ft_path, file))
    end
end

require("luasnip.loaders.from_vscode").lazy_load()

-- ~~~~~~~~~~~~~~~~~~~~~
-- ~ snippet selection ~
-- ~~~~~~~~~~~~~~~~~~~~~

vim.api.nvim_create_user_command('ExpandSnippet', function()
    local snippet_collection = require('luasnip.session.snippet_collection')
    local snippets = snippet_collection.get_snippets('all', 'snippets')

    local ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })
    if ft ~= '' then
        snippets = vim.tbl_extend('force', snippets, snippet_collection.get_snippets(ft, 'snippets'))
    end

    local max_trigger = 0
    local max_name = 0

    for _, s in ipairs(snippets) do
        if #s.trigger > max_trigger then
            max_trigger = #s.trigger
        end

        if #s.name > max_name then
            max_name = #s.name
        end
    end

    vim.ui.select(snippets, {
        prompt = 'Available snippets for "'..ft..'"> ',
        format_item = function(s)
            local trigger = s.trigger .. string.rep(' ', max_trigger - #s.trigger)
            local name = s.name .. string.rep(' ', max_name - #s.name)
            local desc = s.trigger == s.dscr[1] and '' or s.dscr[1]

            return trigger .. ' | ' .. name .. ' | ' .. desc
        end,
    }, function(s)
        if s then
            vim.cmd.normal('a') -- make sure were in insert mode
            require('luasnip').snip_expand(s)
        end
    end)
end, {
    desc = 'Select and expand one of all available snippets',
})

vim.keymap.set('n', '<leader>is', '<CMD>ExpandSnippet<CR>', { desc = 'insert snippet' })
