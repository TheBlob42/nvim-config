local terminal = require('user.plugins.terminal')

---Search upwards from the current path for the 'gradlew' script
---@return string? path Absolute path of the corresponding 'gradlew' script if found
local function get_gradlew_script_path()
    local path
    local buf_name = vim.api.nvim_buf_get_name(0)
    if buf_name:find('^term://') then
        -- in terminal buffer extract cwd from the bufname
        path = vim.fn.expand(buf_name:match('^term://(.-)//'), false, false)
    else
        path = vim.fn.fnameescape(vim.fn.expand('%:p:h'))
    end

    local gradlew_file = vim.fs.find('gradlew', { upward = true, type = 'file', path = path })[1]

    if not gradlew_file or gradlew_file == '' then
        return
    end

    return vim.fn.fnameescape(assert(vim.fn.fnamemodify(gradlew_file, ':p:h')))
end

---Execute a given Gradlew task
---If there is already a terminal buffer corresponding to this task re-use it
---@param task string The task to execute
---@param gradlew_path string? Path to the 'gradlew' script. Will search from the current buffer if not provided
local function gradlew_exec(task, gradlew_path)
    gradlew_path = gradlew_path or get_gradlew_script_path()
    if not gradlew_path then
        vim.api.nvim_echo({{ "No 'gradlew' script was found! Are your within a Gradle project?", 'WarningMsg' }}, false, {})
        return
    end

    terminal.start('gw:'..task, {
        cwd = gradlew_path,
        cmd = './gradlew ' .. task .. '\n',
    }):show({
        location = 'current',
        focus = true,
    })
end

---Extract the task name from a given string
--- | Input                          | Output |
--- |--------------------------------|--------|
--- | [Build] build                  | build  |
--- | [Test] test - test the project | test   |
---@param task_string string Task string returned from 'gradlew tasks'
---@return string The extracted task name
local function get_task_name(task_string)
	local task_with_desc = task_string:match('%[.-%] (.-) %-.+')
	local task_without_desc = task_string:match('%[.-%] (.+)')
	return task_with_desc or task_without_desc
end

local cached_task = {}

---List all available Gradlew tasks for `gradlew_path`
---Execute the one selected by the user
---The extracted tasks are cached for further executions
---@param gradlew_path string? Path to the 'gradlew' script. Will search from the current buffer if not provided
local function task_list(gradlew_path)
    gradlew_path = gradlew_path or get_gradlew_script_path()
    if not gradlew_path then
        vim.api.nvim_echo({{ "No 'gradlew' script was found! Are your within a Gradle project?", 'WarningMsg' }}, false, {})
        return
    end

    if not cached_task[gradlew_path] then
        local status = 'progress'
        local result = ''
        local error_msg = ''
        local stdout = assert(vim.uv.new_pipe())
        local stderr = assert(vim.uv.new_pipe())

        local handle
        ---@diagnostic disable-next-line: missing-fields
        handle = vim.uv.spawn('./gradlew', {
            cwd = gradlew_path,
            args = { 'tasks', '--all' },
            stdio = { nil, stdout, stderr },
        }, function(code)
            if code ~= 0 then
                status = 'error'
            else
                status = 'done'
            end
            vim.uv.close(stdout)
            vim.uv.close(stderr)
            if handle then
                handle:close()
            end
        end)

        vim.uv.read_start(stdout, function(_, data)
            if data then
                result = result .. data
            end
        end)

        vim.uv.read_start(stderr, function(_, data)
            if data then
                error_msg = error_msg .. data
            end
        end)

        -- show loading spinner async
        local src_buf = vim.api.nvim_get_current_buf()
        local timeout = 30000
        local interval = 150
        local time = 0
        local i = 0
        local spinner = { '⠇', '⠋', '⠙', '⠸', '⠴', '⠦' }
        local text = 'loading gradlew tasks %s'
        local spin_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = spin_buf })
        vim.api.nvim_buf_set_lines(spin_buf, 0, -1, false, { text:format(spinner[1]) })
        local spin_win = vim.api.nvim_open_win(spin_buf, false, {
            relative = 'editor',
            anchor = 'SE',
            row = vim.opt.lines:get() - 2,
            col = vim.opt.columns:get(),
            width = #text,
            height = 1,
            focusable = false,
            noautocmd = true,
            border = 'none',
            style = 'minimal',
        })
        vim.api.nvim_set_option_value('winhighlight', 'Normal:NonText', { win = spin_win })
        local spin
        spin = function()
            if status ~= 'progress' then
                vim.api.nvim_win_close(spin_win, true)
                if error_msg ~= '' then
                    return vim.notify('An error occurred while loading the Gradle tasks:\n' .. error_msg, vim.log.levels.WARN, {})
                end

                local tasks = {}
                for group in result:gmatch('[^\n]+ tasks\n[-]+\n[^\n]+.-\n\n') do
                    local group_name = group:match('(.-) tasks')
                    local lines = group:match('[-]+\n(.*)')
                    for line in lines:gmatch('([^\n]+)') do
                        table.insert(tasks, '['..group_name..'] '..line)
                    end
                end

                cached_task[gradlew_path] = tasks

                -- don't open the gradle task selection if the user switched to another buffer (context switch)
                if vim.api.nvim_get_current_buf() == src_buf then
                    task_list(gradlew_path)
                end

                return
            end

            time = time + interval
            if time > timeout then
                vim.notify('Loading the Gradle tasks timed out!', vim.log.levels.ERROR, {})
                vim.api.nvim_win_close(spin_win, true)
                return
            end

            i = i + 1
            vim.api.nvim_buf_set_lines(spin_buf, 0, -1, false, { text:format(spinner[i % vim.tbl_count(spinner) + 1]) })
            vim.defer_fn(spin, interval)
        end
        spin()
        return
    end

    vim.ui.select(cached_task[gradlew_path], {
        prompt = 'Select Gradlew Task> ',
    }, function(task)
        if task then
            gradlew_exec(get_task_name(task), gradlew_path)
        end
    end)
end

-- ~~~~~~~~~~~~~~~~~
-- ~ user commands ~
-- ~~~~~~~~~~~~~~~~~

vim.api.nvim_create_user_command('GradlewClearCache', function(_)
    cached_task = {}
end, { desc = 'clear the cached gradlew tasks' })

vim.api.nvim_create_user_command('GradlewTask', function(opts)
    local task = opts.args
    gradlew_exec(task)
end, { nargs = 1, desc = 'execute gradlew task' })

vim.api.nvim_create_user_command('GradlewList', function(_)
    task_list()
end, { desc = 'list available gradlew tasks' })

return {
    get_gradlew_script_path = get_gradlew_script_path
}
