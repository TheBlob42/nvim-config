local cmp = require('cmp')
-- additional requirements for cmp setup
local luasnip = require('luasnip')
local lspkind = require('lspkind')

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~ "regular" autocompletion ~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cmp.setup {
    enabled = function()
        -- disable cmp for prompt buffers e.g. TelescopePrompt
        if vim.bo.buftype == 'prompt' then
            return false
        end
        return true
    end,
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert {
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete({}),
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
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
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
