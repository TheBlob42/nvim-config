--[[
    Custom statusline configuration with the following features:

    - diagnostic counter (by type)
    - filetype icon + string
    - modified status
    - correctly reset highlights on colorscheme change
    - special cases for drex.nvim and terminal buffers

    Requires the following dependencies:

    - 'gitsigns.nvim' for the current git branch
--]]

local M = {}

-- diagnostic names + corresponding icon and highlight
local diagnostics_attrs = {
    { vim.diagnostic.severity.ERROR, '', 'DiagnosticError' },
    { vim.diagnostic.severity.WARN,  '', 'DiagnosticWarn' },
    { vim.diagnostic.severity.HINT,  '', 'DiagnosticHint' },
    { vim.diagnostic.severity.INFO,  '', 'DiagnosticInfo' },
}

-- in order for our icon highlights to have the correct background color ('StatusLine')
-- we need to create custom highlights by manually combining foreground and background color
local hl_cache = {}
local function get_custom_hl(highlight)
    local fg = vim.api.nvim_get_hl(0, { name = highlight }).fg

    if not fg then
        return 'StatusLine'
    end

    -- check for default NVIM colorscheme
    local colorscheme = vim.g.colors_name or ('default_' .. vim.opt.background:get())
    local key = colorscheme .. '_' .. fg

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
        return active_indicator .. ' ' .. utils.shorten_path(utils.get_root_path(buf), width - 4) .. '%=' .. clipboard_count .. ' '
    end

    if ft == 'gitsigns.blame' then
        return active_indicator .. 'Blame'
    end

    -- for non-special inactive windows only show the file-/buffername
    if not active_win then
        return ' %f%( %m%)'
    end

    -- ~~~~~~~~~~~~~~~~~~
    -- diagnostic counter
    -- ~~~~~~~~~~~~~~~~~~

    local diagnostics = {}

    if vim.diagnostic.is_enabled({ bufnr = buf }) then
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

    -- ~~~~~~~~~~~~~~~~~~
    -- current git branch
    -- ~~~~~~~~~~~~~~~~~~

    local git_branch = vim.b[buf].gitsigns_head
    if git_branch then
        git_branch = '%#' .. get_custom_hl('Comment') .. '#' .. git_branch .. '%*'
    else
        git_branch = ''
    end

    -- ~~~~~~~~~~~~~~~~~~~~~~~~~
    -- several status indicators
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~

    local indicators = ''

    if vim.api.nvim_get_option_value('spell', { win = win }) then
        indicators = indicators .. '🔍 '
     end

    return active_indicator
        .. '%f%( %m%)' -- filename + modified status
        .. ' %<'       -- truncate from here if needed
        .. git_branch
        .. '%= '       -- start righ alignment from here
        .. table.concat(diagnostics)
        .. ' '
        .. filetype
        .. ' %c %P '   -- column count (c) and percentage through file (P)
        .. indicators
end

vim.opt.statusline = '%!v:lua.require("user.plugins.statusline").statusline()'

return M
