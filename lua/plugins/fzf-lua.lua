local fzf = require('fzf-lua')

fzf.setup {
    fzf_colors = {
        ['gutter'] = { 'bg', 'Normal' },
    },
    files = {
        git_icons = false -- remove git icons for better performance
    },
    actions = {
        files = {
            -- default actions (needed since there is not table merge)
            ["default"] = fzf.actions.file_edit_or_qf,
            ["ctrl-s"]  = fzf.actions.file_split,
            ["ctrl-v"]  = fzf.actions.file_vsplit,
            ["ctrl-t"]  = fzf.actions.file_tabedit,
            ["alt-q"]   = fzf.actions.file_sel_to_qf,
            ["alt-l"]   = fzf.actions.file_sel_to_ll,
            -- open a DREX buffer for the cwd
            ['alt-d'] = function(_, opts)
                require('drex').open_directory_buffer(opts.cwd)
            end,
            -- start a live grep search from the cwd
            ['alt-s'] = {
                function(_, opts)
                    fzf.live_grep { cwd = opts.cwd }
                end,
                fzf.actions.resume,
            },
            -- select from buffers rooted in the cwd
            ['alt-b'] = {
                function(_, opts)
                    fzf.buffers {
                        cwd = opts.cwd,
                        fzf_opts = {
                            -- no header lines, make every entry selectable
                            ["--header-lines"] = false
                        },
                    }
                end,
                fzf.actions.resume,
            },
        },
      },
    winopts = {
        preview = {
            delay = 60 -- smoother preview experience
        }
    },
    keymap = {
        builtin = {
            -- default mappings (needed since there is no table merge)
            ["<F1>"] = "toggle-help",
            ["<F2>"] = "toggle-fullscreen",
            ["<F3>"] = "toggle-preview-wrap",
            ["<F4>"] = "toggle-preview",
            ["<F5>"] = "toggle-preview-ccw",
            ["<F6>"] = "toggle-preview-cw",
            -- scroll preview easily
            ["<C-d>"] = "preview-page-down",
            ["<C-u>"] = "preview-page-up",
        },
        fzf = {
            -- default mappings (needed since there is no table merge)
            ["ctrl-z"] = "abort",
            ["ctrl-f"] = "half-page-down",
            ["ctrl-b"] = "half-page-up",
            ["ctrl-a"] = "beginning-of-line",
            ["ctrl-e"] = "end-of-line",
            ["alt-a"]  = "toggle-all",
            ["f3"]     = "toggle-preview-wrap",
            ["f4"]     = "toggle-preview",
            -- scroll preview easily
            ["ctrl-d"] = "preview-page-down",
            ["ctrl-u"] = "preview-page-up",
        },
    },
}

---@class FzfFilesOption
---@field prompt string|function The prompt string for the fzf dialog. Can also be a function which receives the directory path (e.g. '/home/user/projects') and returns the prompt string to use
---@field transform function Function to transform the displayed entries for the fzf dialog. The function receives the list of entries (strings) to display and returns a new list which is then displayed in the fzf dialog. Use it to add, delete or modify the default display entries for your custom use case
---@field actions function Function to create the actions for the fzf dialog. The function receives the directory path (e.g. '/home/user/projects') and the entries map (e.g. `{ ['file.txt'] = { type = 'file', path = '/home/user/file.txt' } }`) as parameters, so they can be used for the definition of custom actions. The return is a map of actions as defined by fzf-lua

---Display the files & directories in `dir` (by default the current working directory)
---By default only allows simple navigation through directories and opening a selected file in the same window
---Pass a `FzfFilesOption` table to further customization of the fzf dialog
---@param dir string? The directory to open in fzf
---@param opts FzfFilesOption? Additional options for customize the fzf dialog
---@see FzfFilesOption
local function files(dir, opts)
    vim.validate {
        dir = { dir, 'string', true },
        opts = { opts, 'table', true }
    }

    dir = assert(dir or vim.loop.cwd())
    dir = vim.fn.fnamemodify(vim.fn.expand(dir), ':p') -- ensure trailing path separator

    local entries = {}
    -- "goto parent" entry only if we're not at root level
    if dir ~= '/' then
        entries[' ..'] = {
            type = 'directory',
            path = vim.fn.fnamemodify(dir, ':p:h:h')
        }
    end

    for name, type in vim.fs.dir(dir) do
        if type == 'directory' then
            entries[' '..name] = {
                type = type,
                path = dir .. name
            }
        else
            local icon = require('nvim-web-devicons').get_icon(name) or ''
            entries[icon..' '..name] = {
                type = type,
                path = dir .. name
            }
        end
    end

    local display_entries = vim.tbl_keys(entries)
    table.sort(display_entries)

    -- "clone" the given options table to prevent modifying the original in case of recursive fn calls
    local options = vim.tbl_extend('force', {}, opts)
    if options.actions then
        -- create the custom actions to make them easier "mergeable" with the defaults
        options.actions = options.actions(dir, entries)
    end
    local defaults_opts = {
        prompt = vim.fn.fnamemodify(dir, ':~') .. '> ',
        transform = nil,
        actions = {
            ['default'] = {
                function(selected)
                    local element = entries[selected[1]]

                    if element.type == 'directory' then
                        files(element.path, opts)
                    else
                        vim.api.nvim_win_close(0, true)
                        vim.cmd.e(element.path)
                    end
                end,
            },
        },
    }
    options = vim.tbl_deep_extend('force', defaults_opts, options)

    if type(options.prompt) == 'function' then
        options.prompt = options.prompt(dir)
    end

    if options.transform then
        display_entries = options.transform(display_entries)
    end

    fzf.fzf_exec(display_entries, {
        prompt = options.prompt,
        actions = options.actions,
        winopts = {
            on_create = function()
                for _, icon in pairs(require('nvim-web-devicons').get_icons()) do
                    vim.fn.matchadd('DevIcon'..icon.name, icon.icon)
                end
            end,
        },
    })
end

local function save_as(directory)
    local create_new = '+ [CREATE NEW FILE]'
    files(directory, {
        prompt = function(dir)
            return 'Save in "'..vim.fn.fnamemodify(dir, ':~')..'"> '
        end,
        transform = function(display_entries)
            table.insert(display_entries, 2, create_new)
            return display_entries
        end,
        actions = function(dir, entries)
            return {
                ['default'] = {
                    function(selected)
                        if selected[1] == create_new then
                            vim.api.nvim_win_close(0, true)
                            local ok, new_file = pcall(vim.fn.input, 'Save as: ', dir)
                            if not ok then
                                return
                            end
                            vim.cmd.w(new_file)
                            return
                        end

                        local element = entries[selected[1]]

                        if element.type == 'directory' then
                            save_as(element.path)
                        else
                            vim.api.nvim_win_close(0, true)
                            local overwrite = vim.fn.confirm('Do you want to overwrite "' .. element.path .. '"?', '&Yes\n&No', 1, 'Question')
                            if overwrite == 1 then
                                local buf = vim.fn.bufnr('^'..element.path..'$')
                                if buf ~= -1 then
                                    -- this could cause problems with large files (for now it should be ok)
                                    vim.fn.writefile(vim.api.nvim_buf_get_lines(0, 0, -1, false), element.path)
                                    vim.api.nvim_buf_call(buf, function()
                                        vim.cmd.e()
                                    end)
                                else
                                    vim.cmd.w(element.path)
                                end
                            end
                        end
                    end
                },
            }
        end,
    })
end

local function file_explorer(directory)
    files(directory, {
        actions = function(dir, entries)
            -- a little helper function to avoid repetition
            local edit_file = function(pre_cmd)
                return {
                    function(selected)
                        local element = entries[selected[1]]

                        if element.type ~= 'directory' then
                            vim.api.nvim_win_close(0, true)
                            if pre_cmd then
                                vim.cmd(pre_cmd)
                            end
                            vim.cmd.e(element.path)
                        else
                            fzf.actions.resume()
                        end
                    end
                }
            end

            return {
                ['alt-d'] = function()
                    require('drex').open_directory_buffer(dir)
                end,
                ['alt-s'] = {
                    function()
                        fzf.live_grep {
                            prompt = 'Search "'..dir..'"> ',
                            cwd = dir,
                        }
                    end,
                    fzf.actions.resume,
                },
                ['alt-t'] = function()
                    local buf = vim.api.nvim_create_buf(true, false)
                    vim.api.nvim_set_current_buf(buf)
                    vim.fn.termopen(vim.o.shell, { cwd = dir })
                end,
                ['alt-b'] = {
                    function()
                        fzf.buffers {
                            cwd = dir,
                            -- no header lines, make every entry selectable
                            fzf_opts = { ["--header-lines"] = false },
                        }
                    end,
                    fzf.actions.resume,
                },
                ['ctrl-v'] = edit_file('vsplit'),
                ['ctrl-x'] = edit_file('split'),
                ['ctrl-t'] = edit_file('tabnew'),
            }
        end,
    })
end

local function switch_project()
    local projects = {}

    for _, project_base_dir in ipairs(my.sys_local.projects.base_dirs) do
        local path = vim.fn.fnamemodify(vim.fn.expand(project_base_dir), ':p')
        for name, type in vim.fs.dir(path) do
            if type == 'directory' then
                projects[name] = path .. name
            end
        end
    end

    for _, project in ipairs(my.sys_local.projects.dirs) do
        local full_path = vim.fn.fnamemodify(vim.fn.expand(project), ':p')
        local name = vim.fn.fnamemodify(full_path, ':h:t')
        projects[name] = full_path
    end

    local display_projects = vim.tbl_keys(projects)
    table.sort(display_projects)

    fzf.fzf_exec(display_projects, {
        prompt = 'Projects> ',
        actions = {
            ['default'] = {
                function(selected)
                    fzf.files {
                        prompt = 'Project files> ',
                        cwd = projects[selected[1]],
                    }
                end,
                fzf.actions.resume,
            },
            ['alt-d'] = function(selected)
                require('drex').open_directory_buffer(projects[selected[1]])
            end,
            ['alt-s'] = {
                function(selected)
                    fzf.live_grep {
                        prompt = 'Search "'..selected[1]..'"> ',
                        cwd = projects[selected[1]],
                    }
                end,
                fzf.actions.resume,
            },
            ['alt-t'] = function(selected)
                local buf = vim.api.nvim_create_buf(true, false)
                vim.api.nvim_set_current_buf(buf)
                vim.fn.termopen(vim.o.shell, { cwd = projects[selected[1]] })
            end,
        }
    })
end

---Simple helper to call git commit functions with custom window options
---@param buffer_only boolean? Only check commits of the current buffer?
---@return function Function that can be used in a keymapping
local function fzf_git(buffer_only)
    local fn = buffer_only and 'bcommits' or 'commits'
    return function()
        require('fzf-lua.providers.git')[fn] {
            winopts = {
                height = 1,
                width = 0.95,
                preview = {
                    layout = 'vertical',
                    vertical = 'down:80%',
                },
            }
        }
    end
end

local mappings = {
    { '<leader>h', '<CMD>FzfLua help_tags<CR>', 'help tags' },
    { '<leader>ff', file_explorer, 'file explorer (cwd)' },
    { '<leader>fF', function() file_explorer('%:h') end, 'file explorer (cwd)' },
    { '<leader>fr', '<CMD>FzfLua oldfiles<CR>', 'recent files' },
    { '<leader>fS', function() save_as('%:h') end, 'save as' },
    { '<leader>gB', fzf_git(true), 'buffer commits' },
    { '<leader>gC', fzf_git(false), 'cwd commits' },
    { '<leader>bb', '<CMD>FzfLua buffers<CR>', 'switch buffer' },
    { '<leader>pp', switch_project, 'switch project' },
    { '<leader>pf', '<CMD>FzfLua files<CR>', 'project files' },
    { '<leader>pb', function() fzf.buffers { cwd_only = true } end, 'project buffers' },
    { '<leader>ss', '<CMD>FzfLua blines<CR>', 'search in current buffer' },
    { '<leader>sd', '<CMD>FzfLua live_grep_native<CR>', 'search in cwd' },
    { '<leader>el', '<CMD>FzfLua diagnostics_document<CR>', 'list errors' },
}

for _, m in ipairs(mappings) do
    local lhs, rhs, desc = unpack(m)
    vim.keymap.set('n', lhs, rhs, { desc = desc })
end
