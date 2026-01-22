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

        -- just separate winbar with a light colored "line"
        local winbar_hl = {
            cterm = { underline = true },
            underline = true,
            sp = vim.api.nvim_get_hl(0, { name = 'CursorLine' }).bg,
        }
        hls['WinBar'] = winbar_hl
        hls['WinBarNC'] = winbar_hl

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
