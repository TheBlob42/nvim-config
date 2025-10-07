---@diagnostic disable-next-line: missing-fields
require('modus-themes').setup {
    on_highlights = function(hls, _)
        -- see `:h lsp-highlight`
        hls['LspReferenceText']  = { link = 'DiffAdd' }
        hls['LspReferenceRead']  = { link = 'DiffAdd' }
        hls['LspReferenceWrite'] = { link = 'DiffAdd' }
        hls['LspSignatureActiveParameter'] = { link = 'CurSearch' }

        -- makes gitsigns better visible (especially in light theme)
        hls['GitSignsAdd']    = { link = '@diff.plus' }
        hls['GitSignsChange'] = { link = '@diff.delta' }
        hls['GitSignsDelete'] = { link = '@diff.minus' }

        -- miscellaneous
        hls['netrwMarkFile']    = { link = 'ErrorMsg' }
        hls['LeapLabel'] = { link = 'Sneak' }
        hls['@markdown.quote']  = { link = 'Comment' }
        hls['@lsp.type.enumMember.markdown'] = { link = 'Keyword' } -- markdown tag
        -- make tabstops better distinguishable
        hls['SnippetTabstop'] = { link = 'MatchParen' }
        hls['SnippetTabstopActive'] = { link = 'Visual' }
    end,
}

vim.cmd.colorscheme('modus')
