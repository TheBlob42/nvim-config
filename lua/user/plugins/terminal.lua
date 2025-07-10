---A simple module to manage terminal buffers
local M = {}

---@class Terminal
---@field name string The name of the terminal
---@field buf number The buffer number of the terminal
---@field job_id number The job id of the terminal
---@field send fun(self: Terminal, cmd: string|table): Terminal Send a command to the terminal
---@field show fun(self: Terminal, opts: ShowOptions?): Terminal, number Show the terminal in a window
---@field close fun(self: Terminal) Close the terminal and clean up
local Terminal = {}

-- this is gonna be used as metatable
Terminal.__index = Terminal

---Retrieve a terminal by its `name` (if it exists)
---@param name string The name of the terminal
---@return Terminal? terminal The found terminal instance
function M.get(name)
    local buf = vim.fn.bufnr('^term://*'..name..'$')
    if buf > 0 then
        local term = {}
        setmetatable(term, Terminal)
        term.name = name
        term.buf = buf
        term.job_id = vim.bo[buf].channel
        return term
    end

    return nil
end

---@class StartupOptions
---@field cwd string? The working directory for the terminal (defaults to the current `cwd`)
---@field cmd string|table? The command to execute in the terminal after startup

---Start a new terminal with the given `name`
---If a terminal with this name already exists return it instead
---@param name string The name of the terminal
---@param opts StartupOptions? Optional options about the terminal startup
---@return Terminal terminal The newly created terminal instance (or the found one)
---@return boolean new_terminal_was_created `true` if a new terminal was created, `false` if an existing one was found
function M.start(name, opts)
    local term = M.get(name)
    if term then
        return term, false
    end

    opts = vim.tbl_extend('keep', opts or {}, {
        cwd = vim.uv.cwd(),
        cmd = '',
    })

    term = setmetatable({}, Terminal)

    local buf = vim.api.nvim_create_buf(true, false)
    -- terminal is spawned in the current buffer
    vim.api.nvim_buf_call(buf, function()
        local job_id = vim.fn.jobstart(vim.o.shell..';#'..name, {
            cwd = vim.fn.fnamemodify(opts.cwd, ':p'),
            term = true,
        })

        term.name = name
        term.buf = buf
        term.job_id = job_id
    end)

    term:send(opts.cmd)

    return term, true
end

---@alias WindowPosition 'current' | 'split' | 'vsplit' | 'float'

---@class ShowOptions
---@field location WindowPosition? The location to show the terminal in (defaults to `current`)
---@field focus boolean? Whether to focus the terminal window (defaults to `true`)

---Show the terminal in a window
---If the terminal is already shown in a window on the current tabpage this does not spawn a new one
---@param opts ShowOptions? Information where and how to show the terminal
---@return Terminal instance Return the terminal instance for easy chaining
---@return integer win The window id in which the terminal is shown
function Terminal:show(opts)
    opts = vim.tbl_extend('keep', opts or {}, {
        location = 'current',
        focus = true,
    })

    local src_win = vim.api.nvim_get_current_win()
    local win = vim.fn.bufwinid(self.buf)
    if win == -1 then
        if opts.location == 'float' then
            local columns = vim.o.columns
            local width = math.floor(columns * 0.8)
            local lines = vim.o.lines
            local height = math.floor(lines * 0.8)

            return self, vim.api.nvim_open_win(self.buf, opts.focus, {
                title = self.name,
                relative = 'editor',
                anchor = 'NW',
                width = width,
                height = height,
                row = math.floor((lines - height) / 2),
                col = math.floor((columns - width) / 2),
                style = 'minimal',
            })
        end

        if opts.location == 'split' then
            vim.cmd.split()
        elseif opts.location == 'vsplit' then
            vim.cmd.vsplit()
        end

        win = vim.api.nvim_get_current_win()

        vim.api.nvim_win_set_buf(win, self.buf)
    end

    if opts.focus then
        vim.api.nvim_set_current_win(win)
    else
        vim.api.nvim_set_current_win(src_win)
    end

    return self, assert(win)
end

---Execute a command in the terminal
---Make sure that the command ends with a newline character if it should be executed
---@param cmd string|table The command to execute. If its a table it will be joined with newlines ('\n')
---@return Terminal instance Return the terminal instance for easy chaining
function Terminal:send(cmd)
    if not cmd or cmd == '' or cmd == {} then
        return self
    end

    -- scroll to bottom
    local win = vim.fn.bufwinid(self.buf)
    if win ~= -1 then
        vim.api.nvim_win_call(win, function()
            vim.cmd.normal { 'G', bang = true }
        end)
    end

    if type(cmd) == 'table' then
        cmd = table.concat(cmd, '\n')
    end

    vim.fn.chansend(self.job_id, cmd)

    return self
end

---Close the terminal and clean up
function Terminal:close()
    vim.fn.chanclose(self.job_id)
    vim.api.nvim_buf_delete(self.buf, { force = true })
end

return M
