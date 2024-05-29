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

-- ~~~~~~~~~~~~~~~~~~~~~~
-- repeatable keymappings
-- ~~~~~~~~~~~~~~~~~~~~~~

---Special handling for `vim-repeat` mappings in terminal buffers
---
---After the mapping execution the `b:changedtick` variable is increment twice (expectation would be to keep it's current value)
---Why exactly this happens I have no idea, but it is probably one of the specialities and edge cases of terminal buffers in general
---However this breaks the usage of `vim-repeat`, so we have to update the corresponding plugin variable to match the new `b:changedtick` value
function my._repeat_map_terminal_check()
    local buf = vim.api.nvim_get_current_buf()
    if vim.api.nvim_get_option_value('buftype', { buf = buf }) == 'terminal' then
        local count = 0
        vim.api.nvim_create_autocmd('TextChanged', {
            group = vim.api.nvim_create_augroup('RepeatTerminalGroup', {}),
            buffer = buf,
            callback = function()
                count = count + 1
                if count > 1 then
                    vim.g.repeat_tick = vim.api.nvim_buf_get_changedtick(buf)
                    return true -- remove the autocmd afterwards
                end
            end
        })
    end
end

---Create a repeatable <Plug> mapping via `vim-repeat` (for normal mode)
---@param plug string Name for the <Plug> mapping. Needs to start with "<Plug>"
---@param rhs string|function Either a mapping string or a function that should be executed
function my.repeat_map(plug, rhs)
    local plugins = vim.tbl_map(function(p) return p[1] end, require('lazy').plugins())
    if plugins and not vim.tbl_contains(plugins, 'tpope/vim-repeat') then
        vim.api.nvim_echo({{ debug.getinfo(2).source .. ' --> `vim-repeat` is not loaded!', 'WarningMsg' }}, true, {})
        return
    end

    if not vim.startswith(plug, '<Plug>') then
        vim.api.nvim_echo({{ 'Invalid <Plug> mapping: `plug` needs to start with "<Plug>"!', 'WarningMsg' }}, true, {})
        return
    end

    local command
    if type(rhs) == 'function' then
        command = function()
            rhs()
            vim.fn['repeat#set'](vim.api.nvim_replace_termcodes(plug, true, false, true), vim.v.count)
            my._repeat_map_terminal_check()
        end
    elseif type(rhs) == 'string' then
        command = rhs
            .. ':call repeat#set("\\' .. plug .. '", v:count)<CR>'
            .. ':lua my._repeat_map_terminal_check()<CR>'
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
