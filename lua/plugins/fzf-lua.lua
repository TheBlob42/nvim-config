local fzf = require('fzf-lua')

fzf.setup {
    fzf_colors = {
        ['gutter'] = { 'bg', 'Normal' },
    },
    files = {
        git_icons = false -- remove git icons for better performance
    },
    winopts = {
        preview = {
            delay = 60 -- smoother preview experience
        }
    },
    keymap = {
        builtin = {
          -- default mappings
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
          -- default mappings
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

local function file_explorer(dir)
    dir = dir or vim.loop.cwd() -- default to the cwd
    dir = vim.fn.fnamemodify(vim.fn.expand(dir), ':p') -- ensure trailing path separator

    local entries = {}

    -- "goto parent" entry only if not at root level
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

    local edit_file = function(pre_cmd)
        return function(selected)
            local element = entries[selected[1]]

            if element.type ~= 'directory' then
                vim.api.nvim_win_close(0, true)
                if pre_cmd then
                    vim.cmd(pre_cmd)
                end
                vim.cmd('e ' .. element.path)
            else
                fzf.actions.resume()
            end
        end
    end

    local display_dir = vim.fn.fnamemodify(dir, ':~')
    local display_entries = vim.tbl_keys(entries)
    table.sort(display_entries)

    fzf.fzf_exec(display_entries, {
        prompt = display_dir..'> ',
        actions = {
            ['default'] = {
                function(selected)
                    local element = entries[selected[1]]

                    if element.type == 'directory' then
                        file_explorer(element.path)
                    else
                        vim.api.nvim_win_close(0, true)
                        vim.cmd('e ' .. element.path)
                    end
                end,
            },
            ['alt-d'] = function()
                require('drex').open_directory_buffer(dir)
            end,
            ['alt-s'] = {
                function()
                    fzf.live_grep {
                        prompt = 'Search "'..display_dir..'"> ',
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
            ['ctrl-v'] = { edit_file('vsplit') },
            ['ctrl-x'] = { edit_file('split') },
            ['ctrl-t'] = { edit_file('tabnew') },
        },
        winopts = {
            on_create = function()
                for _, icon in pairs(require('nvim-web-devicons').get_icons()) do
                    vim.fn.matchadd('DevIcon'..icon.name, icon.icon)
                end
            end,
        },
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

local mappings = {
    { '<leader>h', '<CMD>FzfLua help_tags<CR>', 'help tags' },
    { '<leader>ff', file_explorer, 'file explorer (cwd)' },
    { '<leader>fF', function() file_explorer('%:h') end, 'file explorer (cwd)' },
    { '<leader>fr', '<CMD>FzfLua oldfiles<CR>', 'recent files' },
    { '<leader>bb', '<CMD>FzfLua buffers<CR>', 'switch buffer' },
    { '<leader>pp', switch_project, 'switch project' },
    { '<leader>pf', '<CMD>FzfLua files<CR>', 'project files' },
    { '<leader>pb', function() fzf.buffers { cwd_only = vim.loop.cwd() } end, 'project buffers' },
    { '<leader>ss', '<CMD>FzfLua blines<CR>', 'search in current buffer' },
    { '<leader>sd', '<CMD>FzfLua live_grep_native<CR>', 'search in cwd' },
    { '<leader>el', '<CMD>FzfLua diagnostics_document<CR>', 'list errors' },
}

for _, m in ipairs(mappings) do
    local lhs, rhs, desc = unpack(m)
    vim.keymap.set('n', lhs, rhs, { desc = desc })
end
