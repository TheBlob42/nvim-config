-- ~~~~~~~~~~~~~~~~~~~~~~~~~
--  custom picker functions
-- ~~~~~~~~~~~~~~~~~~~~~~~~~

---Custom picker which lists all entries (files & directories) in `dir` and provides basic navigation
---@param dir string The target directory
local function files(dir)
    dir = dir or vim.uv.cwd()
    local entries = {}

    -- "file" is needed for preview
    -- "_path" is needed for the search action
    -- "is_file" is needed for the confirm action

    if dir ~= '/' then
        table.insert(entries, {
            text = '..',
            icon = { ' ', 'Label' },
            name = '..',
            file = vim.fn.fnamemodify(dir, ':p:h:h'),
            _path = vim.fn.fnamemodify(dir, ':p:h:h'),
        })
    end

    for name, type in vim.fs.dir(dir) do
        if type == 'directory' then
            table.insert(entries, {
                text = name,
                icon = { ' ', 'Label' },
                name = name,
                file = vim.fs.joinpath(dir, name),
                _path = vim.fs.joinpath(dir, name),
            })
        else
            local icon, hl = require('nvim-web-devicons').get_icon(
                name,
                vim.fn.fnamemodify(name, ':e'),
                { default = true })
            table.insert(entries, {
                text = name,
                icon = { icon .. ' ', hl },
                name = name,
                is_file = true, -- separate files from directory entries on confirm
                file = vim.fs.joinpath(dir, name),
                _path = vim.fs.joinpath(dir, name),
            })
        end
    end

    Snacks.picker {
        items = entries,
        title = 'File Explorer ('..vim.fn.fnamemodify(dir, ':~')..')',
        format = function(item)
            local icon, hl = unpack(item.icon)
            return {
                { icon, hl },
                { item.name, 'SnacksPickerLabel' },
            }
        end,
        actions = {
            go_home = function(picker)
                picker:close()
                vim.schedule(function()
                    files(vim.env.HOME)
                end)
            end,
            search = function(picker)
                picker:close()
                vim.schedule(function()
                    Snacks.picker.grep {
                        title = 'Search in "' .. dir .. '"',
                        dirs = { dir }
                    }
                end)
            end,
            open_dir = function(picker)
                picker:close()
                vim.cmd.edit(dir)
            end,
            open_terminal = function(picker)
                picker:close()
                local buf = vim.api.nvim_create_buf(true, false)
                vim.fn.chdir(dir)
                vim.api.nvim_set_current_buf(buf)
                vim.fn.termopen(vim.o.shell, { cwd = dir })
            end,
            save_as = function(picker)
                picker:close()
                local item = picker:current()
                if item then
                    local choice = vim.fn.confirm('Overwrite "'..item.name..'"?', '&Yes\n&No', 1)

                    if choice == 1 then
                        vim.cmd.write{ item.file, bang = true }
                    end
                else
                    local new_file = picker:filter().pattern
                    local choice = vim.fn.confirm('Save to "'..new_file..'"?', '&Yes\n&No', 1)

                    if choice == 1 then
                        local path = vim.split(vim.fs.normalize(new_file), '/', { trimempty = true })
                        for i = 1, vim.tbl_count(path) - 1 do
                            local new_folder = vim.fs.joinpath(dir, unpack(path, 1, i))
                            vim.uv.fs_mkdir(new_folder, 509) -- decimal representation of "775" for chmod
                        end
                        vim.cmd.saveas(vim.fs.joinpath(dir, new_file))
                    end
                end
            end,
        },
        win = {
            input = {
                keys = {
                    ['<C-h>'] = { 'go_home', mode = { 'n', 'i' }},
                    ['<A-w>'] = { 'save_as', mode = { 'n', 'i' }},
                    ['<A-s>'] = { 'search', mode = { 'n', 'i' }},
                    ['<A-d>'] = { 'open_dir', mode = { 'n', 'i' }},
                    ['<A-t>'] = { 'open_terminal', mode = { 'n', 'i' }},
                }
            },
            list = {
                keys = {
                    ['<C-h>'] = { 'go_home', mode = { 'n', 'i' }},
                    ['<A-w>'] = { 'save_as', mode = { 'n', 'i' }},
                    ['<A-s>'] = { 'search', mode = { 'n', 'i' }},
                    ['<A-d>'] = { 'open_dir', mode = { 'n', 'i' }},
                    ['<A-t>'] = { 'open_terminal', mode = { 'n', 'i' }},
                }
            },
        },
        confirm = function(picker, item, action)
            if item then
                picker:close()
                if item.is_file then
                    require('snacks.picker.actions').confirm(picker, item, action)
                else
                    vim.schedule(function()
                        files(item._path)
                    end)
                end
            end
        end,
    }
end

---Custom picker for all files newly added to git, modified or currently untracked
---Basically everything that is differing from the local HEAD
---@param dir string The target directory
local pick_git_files = function(dir)
    local git_root = vim.system(
        { 'git', 'rev-parse', '--show-toplevel' },
        { text = true, cwd = (dir or vim.uv.cwd()) }):wait().stdout:sub(1, -2)

    local git_files = {}
    local get_files = function(cmd, prefix)
        local result = vim.system(cmd, { text = true, cwd = git_root }):wait()
        if result.code ~= 0 then
            return
        end

        for file in vim.gsplit(result.stdout, '\n') do
            if file ~= '' then
                table.insert(git_files, {
                    text = prefix .. ' ' .. file,
                    prefix = prefix,
                    name = file,
                    file = vim.fs.joinpath(git_root, file)
                })
            end
        end
    end

    get_files({ 'git', 'diff', '--name-only' }, '[Modified]')
    get_files({ 'git', 'diff', '--name-only', '--cached' }, '[Staged]')
    get_files({ 'git', 'ls-files', '--others', '--exclude-standard' }, '[Untracked]')

    local color = {
        ['[Modified]'] = 'SnacksPickerGitStatusModified',
        ['[Staged]'] = 'SnacksPickerGitStatusStaged',
        ['[Untracked]'] = 'SnacksPickerGitStatus',
    }

    Snacks.picker {
        items = git_files,
        title = 'Modified GIT files',
        format = function(item)
            return {
                { item.prefix..' ', color[item.prefix] },
                { item.name, 'SnacksPickerFile' }
            }
        end,
    }
end

-- ~~~~~~~~~~~~~~
-- snacks setup
-- ~~~~~~~~~~~~~~

-- wezterm only supports hover preview (no inline)
local image_support = (vim.env.KITTY_PID or vim.env.GHOSTTY_BIN_DIR or vim.env.WEZTERM_EXECUTABLE) and true

require('snacks').setup {
    bigfile = { enabled = true },
    indent = { enabled = true },
    image = { enabled = image_support },
    picker = {
        main = {
            -- all windows can be the main window
            -- https://github.com/folke/snacks.nvim/issues/1155
            file = false,
        },
        actions = {
            search_cwd = function(picker)
                local cwd = picker:current().cwd
                if cwd then
                    picker:close()
                    Snacks.picker.grep {
                        title = 'Search in "'..cwd..'"',
                        dirs = { cwd }
                    }
                end
            end,
            search_file_path = function(picker)
                local path = picker:current()._path
                if path then
                    picker:close()
                    Snacks.picker.grep {
                        title = 'Search in "'..vim.fn.fnamemodify(path, ':p:h')..'"',
                        dirs = { vim.fn.fnamemodify(path, ':p:h') }
                    }
                end
            end,
            open_cwd = function(picker)
                local cwd = picker:current().cwd
                if cwd then
                    picker:close()
                    vim.cmd.edit(cwd)
                end
            end,
            open_file_path = function(picker)
                local path = picker:current()._path
                if path then
                    picker:close()
                    vim.cmd.edit(vim.fn.fnamemodify(path, ':p:h'))
                end
            end,
            open_terminal_cwd = function(picker)
                local cwd = picker:current().cwd
                if cwd then
                    picker:close()
                    local buf = vim.api.nvim_create_buf(true, false)
                    vim.fn.chdir(cwd)
                    vim.api.nvim_set_current_buf(buf)
                    vim.fn.termopen(vim.o.shell, { cwd = cwd })
                end
            end,
            open_terminal_file_path = function(picker)
                local path = picker:current()._path
                if path then
                    local dir = vim.fn.fnamemodify(path, ':p:h')
                    picker:close()
                    local buf = vim.api.nvim_create_buf(true, false)
                    vim.fn.chdir(dir)
                    vim.api.nvim_set_current_buf(buf)
                    vim.fn.termopen(vim.o.shell, { cwd = dir })
                end
            end,
            git_modified_files = function(picker)
                local cwd = picker:current().cwd
                if cwd then
                    picker:close()
                    vim.schedule(function()
                        pick_git_files(cwd)
                    end)
                end
            end,
        },
        win = {
            input = {
                keys = {
                    ['<C-c>'] = { 'cancel', mode = { 'n', 'i' }},
                    ['<a-s>'] = { 'search_cwd', mode = { 'n', 'i' }},
                    ['<a-S>'] = { 'search_file_path', mode = { 'n', 'i' }},
                    ['<a-d>'] = { 'open_cwd', mode = { 'n', 'i' }},
                    ['<a-D>'] = { 'open_file_path', mode = { 'n', 'i' }},
                    ['<a-t>'] = { 'open_terminal_cwd', mode = { 'n', 'i' }},
                    ['<a-T>'] = { 'open_terminal_file_path', mode = { 'n', 'i' }},
                    ['<a-g>'] = { 'git_modified_files', mode = { 'n', 'i' }},
                }
            },
        },
        layout = function()
            if vim.o.columns >= 170 then
                return {
                    layout = {
                        backdrop = false,
                        box = 'vertical',
                        row = -1,
                        width = 0,
                        height = 0.5,
                        border = 'top',
                        title = '{title} {live} {flags}',
                        title_pos = 'left',
                        { win = 'input', height = 1, border = 'bottom' },
                        {
                            box = 'horizontal',
                            { win = 'list', border = 'none' },
                            { win = 'preview', title = '{preview}', width = 0.5, border = 'left' }
                        },
                    }
                }
            end

            return {
                hidden = { 'preview' },
                layout = {
                    backdrop = false,
                    box = 'vertical',
                    row = -1,
                    width = 0,
                    height = 0.5,
                    { win = 'input', title = '{title} {live} {flags}', title_pos = 'left', height = 1, border = 'top' },
                    { win = 'list', border = 'top' },
                    { win = 'preview', title = '{preview}', border = 'top' }
                }
            }
        end,
        formatters = {
            file = {
                -- also show deeply nested file path completely
                -- https://github.com/folke/snacks.nvim/discussions/1355#discussioncomment-12326465
                truncate = 10000
            }
        }
    },
}

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--  picker related key bindings
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

vim.keymap.set('n', '<leader>bb', Snacks.picker.buffers, { desc = 'Switch buffer' })
vim.keymap.set('n', '<leader>cc', Snacks.picker.spelling, { desc = 'correct spelling error' })
vim.keymap.set('n', '<leader>el', Snacks.picker.diagnostics_buffer, { desc = 'List errors' })
vim.keymap.set('n', '<leader>fr', Snacks.picker.recent, { desc = 'Open recent file' })
vim.keymap.set('n', '<leader>ff', files, { desc = 'File explorer' })
vim.keymap.set('n', '<leader>h',  Snacks.picker.help, { desc = 'Search help tags' })
vim.keymap.set('n', '<leader>pb', function()
    Snacks.picker.buffers { filter = { cwd = vim.uv.cwd() }}
end, { desc = 'Switch project buffers' })
vim.keymap.set('n', '<leader>pf', Snacks.picker.files, { desc = 'Open project file' })
vim.keymap.set('n', '<leader>pg', pick_git_files, { desc = 'Modified GIT files' })
vim.keymap.set('n', '<leader>sd', Snacks.picker.grep, { desc = 'Search project files' })

-- file explorer from the directory of the current file (+ oil special case)
vim.keymap.set('n', '<leader>fF', function()
    local path = vim.fn.expand('%:h')
    if vim.startswith(path, 'oil:') then
        path = path:match('^oil://(.*)')
    end
    files(path)
end, { desc = 'File explorer (current)' })

-- search current buffer lines in separate tab for maximum preview space
vim.keymap.set('n', '<leader>ss', function()
    local tab = vim.api.nvim_get_current_tabpage()
    local buf = vim.api.nvim_get_current_buf()

    vim.cmd.tabnew()
    require('user.plugins.tabline').rename_tab('Search...')

    local new_buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_buf_delete(new_buf, { force = true })

    Snacks.picker.lines {
        on_close = function()
            vim.cmd.tabclose()
            vim.api.nvim_set_current_tabpage(tab)
        end
    }
end, { desc = 'Search buffer lines' })

-- custom project picker
vim.keymap.set('n', '<leader>pp', function()
    local longest_name = 0
    local projects = {}

    for _, project_base_dir in ipairs(my.sys_local.projects.base_dirs) do
        local path = assert(vim.fn.fnamemodify(vim.fn.expand(project_base_dir), ':p'))
        for name, type in vim.fs.dir(path) do
            if type == 'directory' then
                table.insert(projects, {
                    text = name,
                    name = name,
                    file = path .. name,
                })
                longest_name = math.max(longest_name, #name)
            end
        end
    end

    for _, project in ipairs(my.sys_local.projects.dirs) do
        local full_path = vim.fn.fnamemodify(vim.fn.expand(project), ':p')
        local name = assert(vim.fn.fnamemodify(full_path, ':h:t'))
        table.insert(projects, {
            text = name,
            name = name,
            file = full_path,
        })
        longest_name = math.max(longest_name, #name)
    end

    longest_name = longest_name + 7
    Snacks.picker {
        items = projects,
        title = 'Switch Project',
        format = function(item)
            return {
                { ('%-'..longest_name..'s'):format(item.name), 'SnacksPickerLabel'},
                { item.file, 'SnacksPickerComment' }
            }
        end,
        confirm = function(picker, item)
            picker:close()
            Snacks.picker.files {
                cwd = item.file
            }
        end,
    }
end, { desc = 'Switch project' })

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--  non-picker related keybindings
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

vim.keymap.set('n', '<leader>gB', Snacks.git.blame_line, { desc = "git blame line" })
vim.keymap.set('n', '<leader>gg', Snacks.lazygit.open, { desc = "open lazygit" })
vim.keymap.set('n', '<leader>bd', Snacks.bufdelete.delete, { desc = 'delete buffer' })
vim.keymap.set('n', '<leader>bD', function()
    Snacks.bufdelete.delete { force = true }
end, { desc = 'force delete buffer' })

-- ~~~~~~~~~~~~~
--  other stuff
-- ~~~~~~~~~~~~~

vim.api.nvim_create_user_command('Highlights', Snacks.picker.highlights, { desc = 'Open highlights picker' })

if vim.fn.executable('nvr') then
    vim.env.GIT_EDITOR = 'nvr -cc split --remote-wait +"CloseFloats" +"set bufhidden=wipe"'
end
