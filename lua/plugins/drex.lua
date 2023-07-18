local utils = require('drex.utils')

vim.keymap.set('n', '<leader>N', '<CMD>DrexDrawerToggle<CR>', { desc = 'toggle drawer' })
vim.keymap.set('n', '<leader>fn', '<CMD>DrexDrawerFindFileAndFocus<CR>', { desc = 'find file in drawer' })

-- add some vinegar flavor
vim.keymap.set('n', '~', '<CMD>Drex ~<CR>', { desc = 'open home dir' })
vim.keymap.set('n', '-', function()
    local path = vim.fn.expand('%:p')
    if path == '' then
        require('drex').open_directory_buffer() -- open at cwd
    else
        require('drex').open_directory_buffer(vim.fn.fnamemodify(path, ':h'))
        require('drex.elements').focus_element(0, path)
    end
end, { desc = 'open parent dir' })

require('drex.config').configure {
    keepalt = true,
    hijack_netrw = true,
    actions = {
        files = {
            delete_cmd = vim.fn.executable('trash-put') == 1 and 'trash-put',
        }
    },
    keybindings = {
        ['n'] = {
            ['~'] = '<CMD>Drex ~<CR>',
            ['-'] = '<CMD>lua require("drex.elements").open_parent_directory()<CR>',
            ['l'] = function()
                local start = vim.api.nvim_win_get_cursor(0)

                while true do
                    require('drex.elements').expand_element()

                    local row = vim.api.nvim_win_get_cursor(0)[1]
                    local lines = vim.api.nvim_buf_get_lines(0, row - 1, row + 2, false)

                    -- special case for files
                    if lines[1] and not utils.is_directory(lines[1]) then
                        return
                    end

                    -- check if a given line is a child element of the expanded element
                    local is_child = function(l)
                        if not l then
                            return false
                        end
                        return vim.startswith(utils.get_element(l), utils.get_element(lines[1]) .. utils.path_separator)
                    end

                    if is_child(lines[2]) and utils.is_directory(lines[2]) and not is_child(lines[3]) then
                        vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
                    else
                        vim.api.nvim_win_set_cursor(0, start)
                        return
                    end
                end
            end,
            -- open with system default application
            ['x'] = function()
                local element = utils.get_element(vim.api.nvim_get_current_line())
                vim.fn.jobstart('xdg-open "' .. element .. '" &', { detach = true })
            end,
            ['X'] = function()
                local path = utils.get_path(vim.api.nvim_get_current_line())
                vim.fn.jobstart('xdg-open "' .. path .. '" &', { detach = true })
            end,
            -- expand every directory in the current buffer
            ['O'] = function()
                local row = 1
                while true do
                    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
                    if utils.is_closed_directory(line) then
                        require('drex.elements').expand_element(0, row)
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
                        require('drex.elements').collapse_directory(0, row)
                    end
                    row = row + 1

                    if row > vim.fn.line('$') then
                        break
                    end
                end
            end,
        },
    },
    on_enter = function()
        vim.cmd('setlocal nonumber')
    end,
}
