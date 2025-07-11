--[[
    Custom statusline configuration with the following features:

    - diagnostic counter (by type)
    - filetype icon + string
    - modified status
    - correctly reset highlights on colorscheme change
    - special cases for oil, git-blame and terminal buffers

    Requires the following dependencies:

    - 'gitsigns.nvim' for the current git branch
--]]

local M = {}

-- diagnostic names + corresponding icon and highlight
local diagnostics_attrs = {
    { vim.diagnostic.severity.ERROR, '', 'DiagnosticError' },
    { vim.diagnostic.severity.WARN,  '', 'DiagnosticWarn' },
    { vim.diagnostic.severity.HINT,  '', 'DiagnosticHint' },
    { vim.diagnostic.severity.INFO,  '', 'DiagnosticInfo' },
}

---If in visual mode return the count of lines, words and characters to be displayed
---@return string result The string to present in the statusline
local function get_visual_counts()
    -- it can fail (no idea why though) which breaks the whole statusline implementation
    local success, wc = pcall(vim.fn.wordcount)
    if success and wc.visual_chars then
        local line_count = math.abs(vim.fn.line('.') - vim.fn.line('v')) + 1
        return ('  %d lines %d words %d chars'):format(line_count, wc.visual_words, wc.visual_chars)
    else
        return ''
    end
end

-- in order for our icon highlights to have the correct background color ('StatusLine')
-- we need to create custom highlights by manually combining foreground and background color
local hl_cache = {}
local function get_custom_hl(highlight)
    local fg = vim.api.nvim_get_hl(0, { name = highlight }).fg

    if not fg then
        return 'StatusLine'
    end

    -- check for default NVIM colorscheme
    local colorscheme = vim.g.colors_name or ('default_' .. vim.o.background)
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

    local active_indicator = ''
    if active_win then
        local mode = vim.api.nvim_get_mode().mode
        local mode_hl = 'StatusLine'

        if vim.startswith(mode, 'R') then
            mode_hl = 'TSRainbowOrange'
        elseif vim.startswith(mode, 'i') or vim.startswith(mode, 't') then
            mode_hl = 'TSRainbowGreen'
        elseif vim.startswith(mode:lower(), 'v') or vim.startswith(mode:lower(), 's') or vim.startswith(mode, '') then
            mode_hl = 'TSRainbowViolet'
        end

        -- active window marker (color change based on the current mode)
        active_indicator = '%#' .. mode_hl .. '#  '
    end

    -- ~~~~~~~~~~~~~~~
    -- "special cases"
    -- ~~~~~~~~~~~~~~~

    if vim.api.nvim_get_option_value('buftype', { buf = buf }) == 'terminal' then
        return active_indicator .. vim.api.nvim_buf_get_name(buf) .. '%*%=%P '
    end

    local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })

    if ft == 'oil' then
        return active_indicator .. ' ' .. vim.api.nvim_buf_get_name(buf):sub(7)
    end

    if ft == 'gitsigns-blame' then
        return active_indicator .. ' Git Blame'
    end

    -- for non-special inactive windows only show the file-/buffername
    if not active_win then
        return ' %f%( %m%)'
    end

    -- ~~~~~~~~~~~~~~~~~~
    -- diagnostic counter
    -- ~~~~~~~~~~~~~~~~~~

    local diagnostic_counts = {}

    if vim.diagnostic.is_enabled({ bufnr = buf }) then
        for _, attr in pairs(diagnostics_attrs) do
            local n = vim.diagnostic.get(buf, { severity = attr[1] })
            if vim.tbl_count(n) > 0 then
                table.insert(diagnostic_counts, string.format(' %%#%s#%s %d', get_custom_hl(attr[3]), attr[2], vim.tbl_count(n)))
            end
        end
    end

    local diagnostics = ''
    if vim.tbl_count(diagnostic_counts) > 0 then
        diagnostics = ' ' .. table.concat(diagnostic_counts) .. '%*'
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

        filetype = '  %#' .. hl .. '#' .. icon .. '%* ' .. ft
    end

    -- ~~~~~~~~~~~~~~~~~~
    -- current git branch
    -- ~~~~~~~~~~~~~~~~~~

    local git_branch = vim.b[buf].gitsigns_head
    if git_branch then
        git_branch = '  %#Comment# ' .. git_branch .. '%*'
    else
        git_branch = ''
    end

    -- ~~~~~~~~~~~~~~~~~~~~~~~~~
    -- several status indicators
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~

    local indicators = ''

    if vim.api.nvim_get_option_value('spell', { win = win }) then
        indicators = indicators .. '  🔍'
    end

    -- ~~~~~~~~~~~~~~~~
    -- final statusline
    -- ~~~~~~~~~~~~~~~~

    return active_indicator
        .. ' %t%( %m%)%*%<'
        .. git_branch
        .. diagnostics
        .. '%='
        .. get_visual_counts()
        .. filetype
        .. '  %02l/%02L:%02c'
        .. indicators
        .. '  '
end

---There are no options to overwrite, this will simply set the `statusline` option accordingly
function M.setup()
    vim.opt.statusline = '%!v:lua.require("user.plugins.statusline").statusline()'
end

return M
