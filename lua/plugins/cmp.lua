---@diagnostic disable: missing-fields
local cmp = require('cmp')

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~ "regular" autocompletion ~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cmp.setup {
    enabled = function()
        -- disable cmp for prompt buffers
        if vim.bo.buftype == 'prompt' then
            return false
        end
        return true
    end,
    snippet = {
        expand = function(args)
            vim.snippet.expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert {
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
        -- similar to `compl-generic` by default
        ['<C-n>'] = cmp.mapping(function()
            if cmp.visible() then
                cmp.select_next_item()
            else
                cmp.complete()
            end
        end),
        ['<C-e>'] = cmp.mapping.close(),
        ['<CR>'] = cmp.mapping.confirm {
            select = false,
        },
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp'},
        { name = 'path'},
    }, {
        { name = 'buffer', keyword_length = 5 },
    }),
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    experimental = {
        ghost_text = true,
    }
}

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
