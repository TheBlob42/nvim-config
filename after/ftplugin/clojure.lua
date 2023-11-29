local buf = vim.api.nvim_get_current_buf()
local bufname = vim.api.nvim_buf_get_name(buf)

--[[
    Attach clojure-lsp to "zipfile://" dependency buffers as well (despite them having no root directory)
    The LS will only run in single file mode anyway so we just use the first clojure-lsp client that we retrieve
--]]
if vim.startswith(bufname, 'zipfile://') then
    local clients = vim.lsp.get_clients({ name = 'clojure_lsp' })
    if not vim.tbl_isempty(clients) then
        vim.lsp.buf_attach_client(buf, clients[1].id)
    end
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- jack-in utility to start a REPL
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

---Helper function for creating a "jack-in" function
---@param cmd string The command that starts the REPL process
---@param root_markers string[]? Optional list of root markers where the REPL should be started (default: current file path)
---@return function jack-in-fn Function which starts the REPL process (to be used in a mapping or user command)
local function jack_in(cmd, root_markers)
    return function()
        local file = vim.fn.expand('%:p')
        ---@diagnostic disable-next-line: param-type-mismatch
        if file ~= '' and vim.loop.fs_stat(file) then
            local path = vim.fn.fnamemodify(file, ':p:h')

            if root_markers then
                local deps = vim.fs.find(root_markers, {
                    path = vim.fn.fnamemodify(file, ':p:h'),
                    upward = true,
                })

                if not vim.tbl_isempty(deps) then
                    path = vim.fn.fnamemodify(deps[1], ':p:h')
                else
                    vim.notify('No root found: ' .. table.concat(root_markers, ', '), vim.log.levels.WARN, {})
                    return
                end
            end

            my.start_terminal('jack-in', cmd, {
                cwd = path,
                win = 'split',
                focus = true,
            })
        else
            vim.notify('Only works from a file buffer', vim.log.levels.WARN, {})
        end
    end
end

local default_clj_cmd = [[clj -Sdeps '{:deps {nrepl/nrepl {:mvn/version "1.1.0"}}}' -M -m nrepl.cmdline]]
local clj_cmd = vim.tbl_get(my.sys_local, 'clojure', 'repl_cmd') or default_clj_cmd

vim.api.nvim_buf_create_user_command(0, 'JackIn', jack_in(clj_cmd, { 'deps.edn' }), {
    desc = 'start a clojure REPL for the current buffer'
})
-- check 'g:conjure#client#clojure#nrepl#connection#auto_repl#cmd'
vim.api.nvim_buf_create_user_command(0, 'JackInBB', jack_in('bb nrepl-server localhost:'..math.random(1111, 9999)), {
    desc = 'start a babashka REPL for the current buffer'
})
