--[[
    Custom tabline configuration that enables setting custom names for tabs
    Call the `setup` function to set the 'tabline' option accordingly

    Exposes the following functions:
    - `rename_tab` will accept a custom name (or prompt the user) for the current tabpage
    - `switch_tab` will switch the current tabpage using `vim.ui.select`
--]]

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

    for i, tab in ipairs(vim.api.nvim_list_tabpages()) do
        local hl = (tab == current) and '%#TabLineSel#' or '%#Tabline#'
        local name = get_tab_name(tab)

        s = s .. string.format('%s%%%dT %s▕', hl, i, name)
    end

    s = s .. '%#TabLineFill#%T'

    return s
end

---Rename the current tabpage
---If a `name` is provided use this one
---Otherwise prompt the user via `vim.ui.input` for a new name
---@param name string?
function M.rename_tab(name)
    local current_tab = api.nvim_get_current_tabpage()

    if name and not name:find('^ +$') then
        tab_labels[current_tab] = name
        vim.cmd.redrawtabline()
        return
    end

    vim.ui.input({
        prompt = 'Enter custom tab name: ',
    }, function(input)
        if input and not input:find('^ +$') then
            tab_labels[current_tab] = input
            vim.cmd.redrawtabline()
        end
    end)
end

---Switch to another tab by using `vim.ui.select` and the tabname labels
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

---There are no options to overwrite, this will simply set the `tabline` option accordingly
function M.setup()
    vim.opt.tabline = '%!v:lua.require("user.plugins.tabline").tabline()'
end

return M
