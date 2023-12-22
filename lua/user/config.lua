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

-- ~~~~~~~~~~~~~~~~~~~~~~~~
-- opening terminals easily
-- ~~~~~~~~~~~~~~~~~~~~~~~~

---@alias winOpenOption
---| '"current"' # Use the current window (default)
---| '"split"' # Split the current window using `:split`
---| '"vsplit"' # Split the current window using `:vsplit`

---@class StartTerminalOptions
---@field cwd string? The working directory for the terminal (defaults to `cwd`)
---@field win winOpenOption? Specify where the terminal window should be opened (defaults to "current")
---@field focus boolean Should the new terminal window be focused (defaults to `false`)

---Create a terminal buffer with the given `name` and use it to start the given `cmd`
---If there is already a terminal buffer with the given `name` it will be reused
---If the reused terminal buffer already has a running job any new invocation will NOT stop the existing job
---
---Terminal buffers have a specific naming conventions including the cwd of the terminal (see `:h terminal-start`)
---Therefore `name` will only be the postfix of the full terminal buffer name
---@param name string The name for the terminal
---@param cmd string The command to execute in the terminal
---@param opts StartTerminalOptions? Optional options how the terminal should be opened
function my.start_terminal(name, cmd, opts)
    -- merge custom & default options
    opts = vim.tbl_extend('keep', opts or {}, {
        cwd = vim.loop.cwd(),
        win = 'current',
        focus = false,
    })

    -- make sure the path is absolute
    local path = vim.fn.fnamemodify(opts.cwd, ':p')
    -- for the terminal buffer we need a shortened path (`~` for HOME)
    local shortened_path = vim.fn.fnamemodify(path, ':~')

    local buf = vim.fn.bufnr('^term://'..shortened_path..'*'..name..'$')
    if buf < 0 then
        buf = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_buf_call(buf, function()
            -- `termopen` always uses the current buffer for the connection
            vim.fn.termopen(vim.o.shell..';#'..name, { cwd = path })
        end)
    end

    assert(buf)

    local win = vim.fn.bufwinid(buf)
    if win == -1 then
        local orig_win = vim.api.nvim_get_current_win()
        if opts.win == 'split' then
            vim.cmd.split()
        elseif opts.win == 'vsplit' then
            vim.cmd.vsplit()
        end
        win = vim.api.nvim_get_current_win()

        if not opts.focus then
            vim.api.nvim_set_current_win(orig_win)
        end

        vim.api.nvim_win_set_buf(win, buf)
    end

    assert(win)

    local job_id = vim.api.nvim_buf_get_var(buf, 'terminal_job_id')
    vim.fn.chansend(job_id, cmd..'\n')
    vim.api.nvim_win_set_cursor(win, { vim.fn.line('$'), 0 })
end

-- ~~~~~~~~~~~~~
-- miscellaneous
-- ~~~~~~~~~~~~~

P = vim.print -- shortening for easier debugging
