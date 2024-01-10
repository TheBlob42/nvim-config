local M = {}

-- diagnostic names + corresponding icon and highlight
local diagnostics_attrs = {
    { 'Error', '', 'DiagnosticError' },
    { 'Warn',  '', 'DiagnosticWarn' },
    { 'Hint',  '', 'DiagnosticHint' },
    { 'Info',  '', 'DiagnosticInfo' },
}

-- in order for our icon highlights to have the correct background color ('StatusLine')
-- we need to create custom highlights by manually combining foreground and background color
local hl_cache = {}
local function get_custom_hl(highlight)
    local fg = vim.api.nvim_get_hl(0, { name = highlight }).fg

    if not fg then
        return 'StatusLine'
    end

    local key = vim.g.colors_name .. '_' .. fg

    if not hl_cache[key] then
        -- replace invalid characters (see ':h group-name')
        local name = string.gsub('StatusLine_' .. key, '[^%w_.@]', '_')
        hl_cache[key] = name
        -- retrieve correct background color and create new custom highlight group
        local bg = vim.api.nvim_get_hl(0, { name = 'StatusLine' }).bg
        vim.api.nvim_set_hl(0, name, { fg = fg, bg = bg })
    end

    return hl_cache[key]
end

-- clear the highlight cache when loading a new colorscheme (which usually resets all highlights)
vim.api.nvim_create_autocmd('ColorSchemePre', {
    group = vim.api.nvim_create_augroup('StatuslineClearHighlightCache', {}),
    pattern = '*',
    callback = function()
        hl_cache = {}
    end,
    desc = 'clear the highlights cache for the statusline',
})

function M.statusline()
    local win = vim.g.statusline_winid
    local buf = vim.api.nvim_win_get_buf(win)
    local active_win = win == vim.api.nvim_get_current_win()

    -- active window marker (color change based on current mode)
    local active_indicator = ''

    if active_win then
        local mode = vim.api.nvim_get_mode().mode
        local mode_hl = 'Title'

        if vim.startswith(mode, 'R') then
            mode_hl = 'WarningMsg'
        elseif vim.startswith(mode, 'i') or vim.startswith(mode, 't') then
            mode_hl = 'String'
        elseif vim.startswith(mode:lower(), 'v') or vim.startswith(mode:lower(), 's') or vim.startswith(mode, '') then
            mode_hl = 'Keyword'
        end

        active_indicator = '%#' .. mode_hl .. '#█%* '
    end

    -- ~~~~~~~~~~~~~~~
    -- "special cases"
    -- ~~~~~~~~~~~~~~~

    if vim.api.nvim_get_option_value('buftype', { buf = buf }) == 'terminal' then
        return active_indicator .. vim.api.nvim_buf_get_name(buf) .. '%=%P '
    end

    local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })
    if ft == 'drex' then
        local utils = require('drex.utils')
        local width = vim.api.nvim_win_get_width(win)
        local clipboard_count = vim.tbl_count(require('drex.clipboard').clipboard)
        return active_indicator .. ' ' .. utils.shorten_path(utils.get_root_path(buf), width - 4) .. '%=' .. clipboard_count
    end

    -- for non-special inactive windows only show the file-/buffername
    if not active_win then
        return ' %t%( %m%)'
    end

    -- ~~~~~~~~~~~~~~~~~~
    -- diagnostic counter
    -- ~~~~~~~~~~~~~~~~~~

    local diagnostics = {}

    if not vim.diagnostic.is_disabled(buf) then
        for _, attr in pairs(diagnostics_attrs) do
            local n = vim.diagnostic.get(buf, { severity = attr[1] })
            if vim.tbl_count(n) > 0 then
                table.insert(diagnostics, string.format(' %%#%s#%d%s', get_custom_hl(attr[3]), vim.tbl_count(n), attr[2]))
            end
        end
    end

    if vim.tbl_count(diagnostics) > 0 then
        table.insert(diagnostics, '%*')
    end

    -- ~~~~~~~~~~~~~
    -- conjure state
    -- ~~~~~~~~~~~~~

    local conjure_state = ''
    if vim.tbl_contains(my.lisps, ft) then
        conjure_state = ' %#' .. get_custom_hl('Comment') .. '#[' .. require('conjure.client')['state-key']() .. ']%*'
    end

    -- ~~~~~~~~~~~~~
    -- filetype icon
    -- ~~~~~~~~~~~~~

    local filetype = ''

    if ft ~= '' then
        local icon, hl = '', 'StatusLine'

        local ok, devicons = pcall(require, 'nvim-web-devicons')
        if ok then
            icon, hl = devicons.get_icon_by_filetype(ft, { default = true })
            hl = get_custom_hl(hl)
        end

        filetype = ft .. ' %#' .. hl .. '#' .. icon .. '%*'
    end

    -- ~~~~~~~~~~~~~~~~~~~~~~~~~
    -- several status indicators
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~

    local indicators = ''

    if vim.api.nvim_get_option_value('spell', { win = win }) then
        indicators = indicators .. '🔍'
    end

    return active_indicator .. '%t%( %m%)' .. conjure_state .. table.concat(diagnostics) .. '%=' .. filetype .. ' %P ' .. indicators
end

vim.opt.statusline = '%!v:lua.require("user.statusline").statusline()'

return M
