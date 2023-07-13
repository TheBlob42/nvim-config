-- global table used for general configuration stuff
-- > static configuration values
-- > utility configuration functions
-- > system local configuration (check "local.lua.sample")
_G.my = {}

-- ~~~~~~~~~~~~~~~~~~~~
-- static configuration
-- ~~~~~~~~~~~~~~~~~~~~

-- supported lisp filetypes used for `conjure`, `cmp-conjure` & `parinfer`
my.lisps = {
    "clojure",
    "fennel",
    "janet",
    "racket",
    "scheme",
    "hy",
    "lisp" ,
}

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- utility configuration functions
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

---Create a repeatable <Plug> mapping via `vim-repeat`
---@param plug string Name for the <Plug> mapping. Needs to start with "<Plug>"
---@param rhs string|function Either a mapping string or a function that should be executed
function my.repeat_map(plug, rhs)
    ---@diagnostic disable-next-line: undefined-global
    if packer_plugins and not vim.tbl_get(packer_plugins, 'vim-repeat') then
        print(debug.getinfo(2).source .. ' --> `vim-repeat` is not loaded!')
        return
    end

    if plug:sub(0, 6) ~= '<Plug>' then
        vim.api.nvim_echo({{ 'Invalid <Plug> mapping: `plug` needs to start with "<Plug>"!', 'WarningMsg' }}, true, {})
        return
    end

    local command
    if type(rhs) == 'function' then
        command = function()
            rhs()
            vim.fn['repeat#set'](vim.api.nvim_replace_termcodes(plug, true, false, true), vim.v.count)
        end
    elseif type(rhs) == 'string' then
        command = rhs .. ':call repeat#set("\\' .. plug .. '", v:count)<CR>'
    else
        vim.api.nvim_echo({{ 'Wrong argument type: `rhs` needs to be a string or a function!', 'WarningMsg' }}, true, {})
        return
    end

    vim.keymap.set('n', plug, command, { silent = true })
end

-- ~~~~~~~~~~~~~
-- miscellaneous
-- ~~~~~~~~~~~~~

P = vim.print -- shortening for easier debugging
