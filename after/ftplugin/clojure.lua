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

-- ~~~~~~~~~~~~~~~~~~~~~~~~~
-- simple-repl Configuration
-- ~~~~~~~~~~~~~~~~~~~~~~~~~

require('which-key').add({
    { '<localleader>e', group = 'Evaluate' },
    { '<localleader>t', group = 'Testing' },
})

local rname = 'clojure'
local cmd = vim.tbl_get(my, 'sys_local', 'clojure', 'repl_cmd') or 'clojure'

local repl = require('simple-repl')
local ts = require('simple-repl.tree')

vim.keymap.set('n', '<localleader>c', function()
    repl.open_repl(rname, {
        create = {
            cmd = cmd,
            path = vim.fs.root(0, 'deps.edn'),
        },
        open = {
            win = 'vsplit',
        },
    })
end, { buffer = true, desc = 'Open Clojure REPL' })

vim.keymap.set('n', '<localleader>C', function()
    repl.open_repl(rname, {
        create = {
            cmd = cmd,
            path = vim.fs.root(0, 'deps.edn'),
        },
        open = {
            win = 'hud',
        },
    })
end, { buffer = true, desc = 'Open Clojure REPL in HUD' })

-- ~~~~~~~~~~~~~~~~~~~~~~
-- Evaluation Keybindings
-- ~~~~~~~~~~~~~~~~~~~~~~

vim.keymap.set('x', '<localleader>e', function()
    repl.v_send_to_repl(rname)
end, { buffer = true, desc = 'Send selection to REPL' })

vim.keymap.set('n', '<localleader>eo', function()
    repl.op_send_to_repl(rname)
end, { buffer = true, desc = 'Send VIM motion to REPL' })

-- send all non-comments & non-quotes expressions one after another to the REPL (not at once)
vim.keymap.set('n', '<localleader>eb', function()
    for n in vim.treesitter.get_node():tree():root():iter_children() do
        local _, name = pcall(vim.treesitter.get_node_text, n:named_child(0), 0)
        if n:type() == 'comment' or n:type() == 'quoting_lit' or name == 'quote' then
            -- nothing
        else
           local text = vim.treesitter.get_node_text(n, 0)
           repl.send_to_repl(rname, { text })
       end
    end
end, { buffer = true, desc = 'Send the whole buffer to REPL' })

vim.keymap.set('n', '<localleader>ee', function()
    local text = ts.find_node('list_lit')
    repl.send_to_repl(rname, text)
end, { buffer = true, desc = 'Send current form to REPL' })

vim.keymap.set('n', '<localleader>eE', function()
    local text = ts.find_node_by_parent('source')
    repl.send_to_repl(rname, text)
end, { buffer = true, desc = 'Send current root form to REPL' })

-- ~~~~~~~~~~~~~~~~~~~~
-- TS Utility Functions
-- ~~~~~~~~~~~~~~~~~~~~

---Simple utility to shorten TS query creation
---@param s string
---@return vim.treesitter.Query
local function query(s)
    return vim.treesitter.query.parse('clojure', s)
end

---Extract the namespace from the current Clojure buffer
---@return string? ns The namespace of the current buffer
local function get_namespace()
    return ts.query_from_root(query('((sym_lit) @ns (#eq? @ns "ns") (sym_lit) @ns-name)'), 'ns-name')[1]
end

---Extract the name of the current top-level form
---```clojure
---(defn some-fn [] (let ...)) ;; => "some-fn"
---```
---@return string? name The name of this form
local function get_root_form()
    return ts.query_from_node_by_parent('source', query('((list_lit (sym_lit) (sym_lit) @name))'), 'name')[1]
end

-- ~~~~~~~~~~~~~~~
-- Clojure Testing
-- ~~~~~~~~~~~~~~~

vim.keymap.set('n', '<localleader>tt', function()
    local namespace = get_namespace()
    local name = get_root_form()
    if namespace and name and namespace ~= name then
        -- save test name, so we can easy rerun it at a later point
        _G.last_clojure_test = namespace.."/"..name
        repl.send_to_repl(rname, {"(clojure.test/test-vars [#'"..namespace.."/"..name.."])"})
    end
end, { buffer = true, desc = 'Run the Clojure test at cursor position' })

vim.keymap.set('n', '<localleader>tl', function()
    if _G.last_clojure_test then
        repl.send_to_repl(rname, {"(clojure.test/test-vars [#'".._G.last_clojure_test.."])"})
    end
end, { buffer = true, desc = 'Run the last test again' })

vim.keymap.set('n', '<localleader>tT', function()
    local namespace = get_namespace()
    if namespace then
        repl.send_to_repl(rname, {"(clojure.test/run-tests '"..namespace..")"})
    end
end, { buffer = true, desc = 'Run all Clojure tests in the current namespace' })

vim.keymap.set('n', '<localleader>en', function()
    local namespace = get_namespace()
    if namespace then
        repl.send_to_repl(rname, {
            "(do",
            "  (in-ns '"..namespace..")",
            "  (clojure.core/require '"..namespace.."))",
        })
    end
end, { buffer = true, desc = 'Switch to file local namespace' })

vim.keymap.set('n', '<localleader>eN', function()
    local namespace = get_namespace()
    local text = ts.find_node_by_parent('source')
    if namespace then
        --[[
            - save the current namespace
            - switch to new namespace
            - require namespace to load dependencies
            - evaluate root form
            - switch back to original namespace
        --]]
        repl.send_to_repl(rname, { "(intern 'user 'ns *ns*)" })
        repl.send_to_repl(rname, {
            "(do (in-ns '"..namespace..")",
            "    (clojure.core/require '"..namespace.."))",
        })
        repl.send_to_repl(rname, text)
        repl.send_to_repl(rname, { '(in-ns (ns-name user/ns))' })
    else
        vim.notify('No namespace found', vim.log.levels.WARN, {})
    end
end, { buffer = true, desc = 'Evaluate root form in file local namespace' })

