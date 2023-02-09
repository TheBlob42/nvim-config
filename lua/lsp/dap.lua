local M = {}

local dap = require('dap')
local dapui = require('dapui')

local dap_controls = -1

-- simple DAP REPL autocompletion
vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('DapReplCompletion', {}),
    pattern = 'dap-repl',
    callback = function()
        require('dap.ext.autocompl').attach()
    end,
    desc = 'attach simple autocompletion in dap-repl'
})

vim.fn.sign_define('DapBreakpoint',          { text = '', texthl = 'DiagnosticError' })
vim.fn.sign_define('DapBreakpointCondition', { text = '', texthl = 'DiagnosticInformation' })
vim.fn.sign_define('DapLogPoint',            { text = '', texthl = 'DiagnosticInformation' })
vim.fn.sign_define('DapBreakpointRejected',  { text = '', texthl = 'DiagnosticHint' })

dapui.setup {
    layouts = {
        {
            elements = { 'scopes', 'breakpoints', 'stacks' },
            size = 40,
            position = 'left',
        },
        {
            elements = { 'console' },
            size = 0.3,
            position = 'bottom',
        }
    },
    controls = {
        element = 'console',
    }
}
-- automatically open and close the `dapui` windows
dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open { reset = true }
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close {}
    if vim.api.nvim_win_is_valid(dap_controls) then
        vim.api.nvim_win_close(dap_controls, true)
    end
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close {}
    if vim.api.nvim_win_is_valid(dap_controls) then
        vim.api.nvim_win_close(dap_controls, true)
    end
end

function M.setup_mappings(bufnr)
    vim.keymap.set('n', '<localleader>dU', dapui.toggle, { buffer = bufnr, desc = 'toggle DAP UI' })

    -- session
    vim.keymap.set('n', '<localleader>dr', dap.continue,  { buffer = bufnr, desc = 'start or continue debug session' })
    vim.keymap.set('n', '<localleader>dl', dap.run_last,  { buffer = bufnr, desc = 'run last debug configuration' })
    vim.keymap.set('n', '<localleader>dT', dap.disconnect, { buffer = bufnr, desc = 'terminate current debug session' })

    -- steps
    vim.keymap.set('n', '<F10>', dap.step_over, { buffer = bufnr, desc = 'step over' })
    vim.keymap.set('n', '<F11>', dap.step_into, { buffer = bufnr, desc = 'step into' })
    vim.keymap.set('n', '<F12>', dap.step_out,  { buffer = bufnr, desc = 'step out' })

    -- breakpoints
    vim.keymap.set('n', '<localleader>dbb', dap.toggle_breakpoint, { buffer = bufnr, desc = 'toggle breakpoint' })
    vim.keymap.set('n', '<localleader>dbB', function()
        vim.ui.input({ prompt = 'Breakpoint condition: ' }, function(condition)
            dap.set_breakpoint(condition)
        end)
    end, { buffer = bufnr, desc = 'set breakpoint with condition' })
    vim.keymap.set('n', '<localleader>dbl', function()
        dap.list_breakpoints()
        vim.cmd('copen')
    end, { buffer = bufnr, desc = 'list breakpoints' })
    vim.keymap.set('n', '<localleader>dbC', dap.clear_breakpoints, { buffer = bufnr, desc = 'clear all breakpoints' })
end

local function open_dap_controls_win()
    local lines = {
        " [c] - continue   [n] - step over ",
        " [T] - terminate  [i] - step into ",
        " [R] - open REPL  [o] - step out  ",
    }

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    vim.keymap.set('n', 'q', '<cmd>q<cr>',  { buffer = buf })
    vim.keymap.set('n', 'c', dap.continue,  { buffer = buf })
    vim.keymap.set('n', 'n', dap.step_over, { buffer = buf })
    vim.keymap.set('n', 'i', dap.step_into, { buffer = buf })
    vim.keymap.set('n', 'o', dap.step_out,  { buffer = buf })
    vim.keymap.set('n', 'T', function()
        vim.api.nvim_win_close(0, true)
        dap.disconnect()
    end, { buffer = buf })
    vim.keymap.set('n', 'R', function()
        vim.api.nvim_win_close(0, true)
        dapui.float_element('repl', {})
    end, { buffer = buf })

    -- show the window at the top middle position
    dap_controls = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        anchor = 'NW',
        width = #lines[1],
        height = #lines,
        row = 0,
        col = (vim.opt.columns:get() - #lines[1]) / 2,
        border = 'single',
        style = 'minimal',
    })

    -- automatically close the dap controls window when leaving the controls buffer
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    vim.api.nvim_create_autocmd('BufLeave', {
        buffer = buf,
        desc = 'close dap control window automatically',
        callback = function()
            vim.api.nvim_win_close(dap_controls, true)
            dap_controls = -1
        end,
    })

    -- highlight the command keys
    vim.fn.matchadd('@number', '\\[\\zs.\\ze\\]', 1)
end

vim.keymap.set('n', '<leader>D', open_dap_controls_win, { desc = "open the DAP control window" })

return M
