vim.cmd.colorscheme('modus')

local link = function(hl, target)
    vim.api.nvim_set_hl(0, hl, { link = target })
end

local function update_highlights()
    -- see `:h lsp-highlight`
    link('LspReferenceText', 'DiffAdd')
    link('LspReferenceRead', 'DiffAdd')
    link('LspReferenceWrite', 'DiffAdd')
    link('LspSignatureActiveParameter', 'CurSearch')

    link('LeapLabelPrimary', 'Sneak')
    link('@lsp.type.enumMember.markdown', 'Keyword') -- markdown tags
end

update_highlights()

vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('HighlightAdaptions', {}),
    pattern = 'modus*',
    callback = update_highlights,
})
