local status_ok, drex, config, utils = my.req('drex', 'drex.config', 'drex.utils')
if not status_ok then
    return
end

vim.keymap.set('n', '<leader>N', '<CMD>DrexDrawerToggle<CR>', { desc = 'toggle drawer' })
vim.keymap.set('n', '<leader>fF', '<CMD>DrexDrawerFindFileAndFocus<CR>', { desc = 'find file in drawer' })

-- add some vinegar flavor
vim.keymap.set('n', '~', '<CMD>Drex ~<CR>', { desc = 'open home dir' })
vim.keymap.set('n', '-', function()
    local path = vim.fn.expand('%:p')
    if path == '' then
        drex.open_directory_buffer() -- open at cwd
    else
        drex.open_directory_buffer(vim.fn.fnamemodify(path, ':h'))
        drex.focus_element(0, path)
    end
end, { desc = 'open parent dir' })

config.configure {
    hijack_netrw = true,
    keybindings = {
        ['n'] = {
            ['~'] = '<CMD>Drex ~<CR>',
            ['-'] = '<CMD>lua require("drex").open_parent_directory()<CR>',
            -- open with system default application
            ['X'] = function()
                local path = utils.get_element(vim.api.nvim_get_current_line())
                vim.fn.jobstart("xdg-open '" .. path .. "' &", { detach = true })
            end,
            -- expand every directory in the current buffer
            ['O'] = function()
                local row = 1
                while true do
                    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
                    if utils.is_closed_directory(line) then
                        drex.expand_element(0, row)
                    end
                    row = row + 1

                    if row > vim.fn.line('$') then
                        break
                    end
                end
            end,
            -- collapse every directory in the current buffer
            ['C'] = function()
                local row = 1
                while true do
                    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
                    if utils.is_open_directory(line) then
                        drex.collapse_directory(0, row)
                    end
                    row = row + 1

                    if row > vim.fn.line('$') then
                        break
                    end
                end
            end,
            -- make regular search work only on element names (instead of whole paths)
            ['/'] = function()
                local look_ahead = '\\(.*\\/\\)\\@!'
                local left = vim.api.nvim_replace_termcodes('<LEFT>', true, false, true)
                vim.api.nvim_feedkeys('/.*'..look_ahead..string.rep(left, #look_ahead), 'n', true)
            end,
        },
    },
    on_enter = function()
        vim.cmd('setlocal nonumber')
    end,
}
