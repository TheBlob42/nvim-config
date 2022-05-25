---Search upwards from the current path for the 'gradlew' script
---@return string Absolute path of the corresponding 'gradlew' script or `nil` if not found
local function get_gradlew_script_path()
    local path
    local buf_name = vim.api.nvim_buf_get_name(0)
    if buf_name:find('^term://') then
        -- in terminal buffer extract cwd from the bufname
        path = vim.fn.expand(buf_name:match('^term://(.-)//'))
    else
        path = vim.fn.fnameescape(vim.fn.expand('%:p:h'))
    end

    local gradlew_file = vim.fn.findfile('gradlew', path .. ';')

    if gradlew_file == '' then
        return
    end

    return vim.fn.fnameescape(vim.fn.fnamemodify(gradlew_file, ':p:h'))
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

    -- terminal buffer names use the short (~) version for the home folder
    local escaped_path = vim.fn.fnamemodify(gradlew_path, ":~")
    local buf = vim.fn.bufnr("^term://" .. escaped_path .. "*gw:" .. task .. "$")

    if buf < 0 then
        -- create a new terminal buffer
        buf = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_buf_call(buf, function()
            -- `termopen` always uses the current buffer for the connection
            vim.fn.termopen(vim.o.shell .. ';#gw:' .. task, { cwd = gradlew_path })
        end)
    end

    local win = vim.fn.bufwinid(buf)
    if win == -1 then
        win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(win, buf)
    end

    local job_id = vim.api.nvim_buf_get_var(buf, 'terminal_job_id')
    vim.fn.jobsend(job_id, './gradlew ' .. task .. '\n')

    vim.api.nvim_set_current_win(win)
    vim.api.nvim_win_call(win, function() vim.cmd('normal! G') end)
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
        local stdout = vim.loop.new_pipe()
        vim.loop.spawn('./gradlew', {
            cwd = gradlew_path,
            args = { 'tasks', '--all' },
            stdio = { nil, stdout, nil },
        }, function(code)
            if code ~= 0 then
                status = 'error'
            else
                status = 'done'
            end
            vim.loop.close(stdout)
        end)
        vim.loop.read_start(stdout, function(err, data)
            if err then
                status = 'error'
            elseif data then
                result = result .. data
            end
        end)

        local stages = { '⠇', '⠋', '⠙', '⠸', '⠴', '⠦' }
        local index = #stages
        while true do
            vim.cmd('redraw')
            if status == 'progress' then
                vim.wait(100)
                index = index + 1
                vim.api.nvim_echo({{ 'loading gradlew tasks ' .. stages[math.fmod(index, #stages) + 1], 'Normal' }}, false, {})
            elseif status == 'error' then
                -- TODO
                return
            else
                break
            end
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
    end

    vim.ui.select(cached_task[gradlew_path], {
        prompt = 'Select Gradlew Task',
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
