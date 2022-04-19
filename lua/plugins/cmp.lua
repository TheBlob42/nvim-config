local status_ok, cmp, luasnip, lspkind = my.req('cmp', 'luasnip', 'lspkind')
if not status_ok then
    return
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~ "regular" autocompletion ~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cmp.setup {
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert {
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.close(),
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        },
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp'},
        { name = 'luasnip'},
        { name = 'path'},
    }, {
        { name = 'buffer', keyword_length = 5 },
    }),
    formatting = {
        format = lspkind.cmp_format({ with_text = true, maxwidth = 50 }),
    },
    experimental = {
        ghost_text = true,
    }
}

-- setup `conjure` for all lisps file types
for _, ft in ipairs(my.lisps) do
    cmp.setup.filetype(ft, {
        sources = cmp.config.sources({
            { name = 'conjure' }
        }, {
            { name = 'buffer' }
        })
    })
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~ command line autocompletion ~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})

cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'cmdline' }
    }
})
