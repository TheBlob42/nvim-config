local status_ok, dap, dapui = my.req('dap', 'dapui')
if not status_ok then
    return
end

-- simple DAP REPL autocompletion
vim.api.nvim_create_augroup('DapReplCompletion', {})
vim.api.nvim_create_autocmd('FileType', {
    group = 'DapReplCompletion',
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

dapui.setup()
-- automatically open and close the `dapui` windows
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

return {
    setup_mappings = function(bufnr)
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
        vim.keymap.set('n', '<localleader>dbl', dap.list_breakpoints, { buffer = bufnr, desc = 'list breakpoints' })
        vim.keymap.set('n', '<localleader>dbC', dap.clear_breakpoints, { buffer = bufnr, desc = 'clear all breakpoints' })
    end
}
