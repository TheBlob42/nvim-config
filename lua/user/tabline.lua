local M = {}

local api = vim.api
local tab_labels = {}

---Retrieve the name for the given tab
---@param t number ID of the tabpage
---@return string The respective name for the tab
local function get_tab_name(t)
    local name = vim.fn.fnamemodify(api.nvim_buf_get_name(api.nvim_win_get_buf(api.nvim_tabpage_get_win(t))), ':t') or ''
    if name == '' then
        name = '[No Name]'
    end

    local label = tab_labels[t]
    if label and label ~= '' then
        name = label
    end

    return name
end

function M.tabline()
    local current = vim.api.nvim_get_current_tabpage()
    local s = ''

    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        local hl = (tab == current) and '%#TabLineSel#' or '%#Tabline#'
        local name = get_tab_name(tab)

        s = s .. string.format('%s%%%dT %s▕', hl, tab, name)
    end

    s = s .. '%#TabLineFill#%T'

    return s
end

function M.rename_tab()
    local current_tab = api.nvim_get_current_tabpage()
    vim.ui.input({
        prompt = 'Enter custom tab name: ',
        default = tab_labels[current_tab],
    }, function(input)
        tab_labels[current_tab] = input
        vim.cmd.redrawtabline()
    end)
end

function M.switch_tab()
    local tabs = vim.tbl_map(function(tabpage)
        return { tabpage, get_tab_name(tabpage) }
    end, vim.api.nvim_list_tabpages())

    vim.ui.select(tabs, {
        prompt = 'Switch to another tab> ',
        format_item = function(tab)
            return tab[2]
        end
    }, function(tab)
        if tab then
            vim.api.nvim_set_current_tabpage(tab[1])
        end
    end)
end

vim.opt.tabline = '%!v:lua.require("user.tabline").tabline()'

return M
