-- regarding vim-surround we do not have to do anything
-- https://github.com/ggandor/lightspeed.nvim/discussions/83

vim.g.lightspeed_no_default_keymaps = true

local mappings = {
    -- default to bi-directional search (omni)
    { 'n', 's', '<Plug>Lightspeed_omni_s' },
    { 'x', 's', '<Plug>Lightspeed_omni_s' },
    { 'o', 'z', '<Plug>Lightspeed_omni_s' },
    { 'n', 'gs', '<Plug>Lightspeed_omni_gs' },
    -- default bindings for f/t/F/T
    { 'n', 'f', '<Plug>Lightspeed_f' },
    { 'n', 'F', '<Plug>Lightspeed_F' },
    { 'x', 'f', '<Plug>Lightspeed_f' },
    { 'x', 'F', '<Plug>Lightspeed_F' },
    { 'o', 'f', '<Plug>Lightspeed_f' },
    { 'o', 'F', '<Plug>Lightspeed_F' },
    { 'n', 't', '<Plug>Lightspeed_t' },
    { 'n', 'T', '<Plug>Lightspeed_T' },
    { 'x', 't', '<Plug>Lightspeed_t' },
    { 'x', 'T', '<Plug>Lightspeed_T' },
    { 'o', 't', '<Plug>Lightspeed_t' },
    { 'o', 'T', '<Plug>Lightspeed_T' },
    { 'n', ';', '<Plug>Lightspeed_;_ft' },
    { 'x', ';', '<Plug>Lightspeed_;_ft' },
    { 'o', ';', '<Plug>Lightspeed_;_ft' },
    { 'n', ',', '<Plug>Lightspeed_,_ft' },
    { 'x', ',', '<Plug>Lightspeed_,_ft' },
    { 'o', ',', '<Plug>Lightspeed_,_ft' },
}

for _, mapping in ipairs(mappings) do
    local mode, lhs, rhs = unpack(mapping)
    vim.api.nvim_set_keymap(mode, lhs, rhs, { noremap = false })
end

vim.api.nvim_create_autocmd('User', {
    desc = 'fix for https://github.com/ggandor/lightspeed.nvim/issues/140',
    pattern = 'LightspeedSxLeave',
    callback = function()
        local ignore = vim.tbl_contains({ 'terminal', 'prompt' }, vim.opt.buftype:get())
        if vim.opt.modifiable:get() and not ignore then
            vim.cmd('normal! a')
        end
    end,
})
