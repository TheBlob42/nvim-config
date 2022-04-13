-- for this command to work you need a 'validate_jenkinsfile.sh' script within your PATH

-- ~~~~~~~~~~ BLUEPRINT ~~~~~~~~~~
-- #!/bin/bash
--
-- USERNAME="<username>"
-- PASSWORD="<password>"
-- JENKINS_URL="<jenkins host URL>"
--
-- JENKINS_FILE_NAME=$1
--
-- curl -sS --user $USERNAME:$PASSWORD -X POST -F "jenkinsfile=<$JENKINS_FILE_NAME" $JENKINS_URL/pipeline-model-converter/validate
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

vim.api.nvim_create_user_command('ValidateJenkinsfile', function(opts)
    if vim.fn.executable('validate_jenkinsfile.sh') == 0 then
        vim.api.nvim_echo({{ "'validate_jenkinsfile.sh' was not found in PATH, but is necessary to run this command!", 'ErrorMsg' }}, false, {})
        return
    end

    local file = opts.args
    if file == '' then
        -- if no file was provided, use the one associated with the current buffer
        file = vim.fn.expand("%")

        if file == '' then
            vim.api.nvim_echo({{ 'The current buffer is not associated with a file!', 'ErrorMsg' }}, false, {})
            return
        end
    end

    vim.cmd('!validate_jenkinsfile.sh ' .. file)
end, { nargs = '?', complete = 'file', desc = 'validate a jenkinsfile' })
