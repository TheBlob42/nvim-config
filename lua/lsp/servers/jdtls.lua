local jdtls = require('jdtls')
local dap = require('dap')

-- use to check if jdtls, java-debug-adapter & java-test are installed
local mason_registry = require('mason-registry')
local mason_pkg_path = require('mason.settings').current.install_root_dir .. '/packages'
local lombok_jar = mason_pkg_path .. '/jdtls/lombok.jar'

local function jdtls_on_attach(client, bufnr)
    -- https://github.com/ibhagwan/fzf-lua/issues/310#issuecomment-1013950684
    if vim.api.nvim_buf_get_option(bufnr, 'bufhidden') == 'wipe' then return end

    require('lsp.utils').on_attach(client, bufnr)

    -- initialize dap for jdtls (only if 'java-debug' is installed)
    if mason_registry.is_installed('java-debug-adapter') then
        jdtls.setup_dap {
            hotcodereplace = 'auto'
        }
        require("jdtls.dap").setup_dap_main_class_configs()
        require('lsp.dap').setup_mappings(bufnr)

        -- jdtls specific DAP keybindings
        vim.keymap.set('n', '<localleader>dR', require('jdtls.dap').setup_dap_main_class_configs, { buffer = bufnr, desc = 'reload main class config' })
        vim.keymap.set('n', '<localleader>dG', function()
            dap.run {
                type = 'java',
                request = 'attach',
                name = 'gradle attach',
                hostName = '127.0.0.1',
                port = 5005,
            }
        end, { buffer = bufnr, desc = 'attach to gradle' })

        -- jdtls specific keybindings for running tests (only if 'vscode-java-test' is installed)
        if mason_registry.is_installed('java-test') then
            vim.keymap.set('n', '<localleader>dtt', require('jdtls').test_nearest_method, { buffer = bufnr, desc = 'test method'})
            vim.keymap.set('n', '<localleader>dtc', require('jdtls').test_class, { buffer = bufnr, desc = 'test class'})
        end
    end

    -- add jdtls specific commands
    require('jdtls.setup').add_commands()

    -- add jdtls specific keybindings
    vim.keymap.set('n', '<localleader>i', jdtls.organize_imports, { buffer = bufnr, desc = 'organize imports' })
    vim.keymap.set('n', '<localleader>R', '<CMD>JdtWipeDataAndRestart<CR>', { buffer = bufnr, desc = 'reload project'})
end

local function start()
    if mason_registry.is_installed('jdtls') then
        local root_dir = require('jdtls.setup').find_root({ 'gradlew', 'pom.xml', 'mvnw' })
        local workspace_dir = vim.fn.fnamemodify(my.sys_local.java.workspace_dir, ':p') .. vim.fn.fnamemodify(root_dir, ':p:h:t')

        -- to prevent multiple LSPs spawned per project (e.g. gradle multi projects)
        if not root_dir then
            return
        end

        -- workaround for the gradle buildship issue:
        -- https://github.com/mfussenegger/nvim-jdtls/issues/38
        if root_dir ~= nil then
            local build_gradle_file = io.open(root_dir .. "/build.gradle", "r")
            if build_gradle_file ~= nil then
                io.close(build_gradle_file)
                vim.api.nvim_exec([[ let test#java#runner = 'gradletest' ]], true)
                os.execute('rm -rf ' .. root_dir .. '/.settings')
            end
        end

        local config = {
            root_dir = root_dir,
            capabilities = require('lsp.utils').capabilities,
            on_attach = jdtls_on_attach,
        }

        -- choose the jdtls cmd: either the new "jdtls" python script or the "oldschool" java command
        local python_version = vim.tbl_map(tonumber, { vim.fn.system('python3 --version'):match('(%d+)%.(%d+)') })
        if not vim.tbl_isempty(python_version) and python_version[1] >= 3 and python_version[2] >= 9 then
            -- requires python version 3.9 for the 'jdtls' script
            config.cmd = {
                'jdtls',
                '-configuration', mason_pkg_path .. '/jdtls/config_' .. vim.loop.os_uname().sysname:lower(),
                '--jvm-arg=-javaagent:' .. lombok_jar,
                '--jvm-arg=-Xbootclasspath/a:' .. lombok_jar,
                '-data', workspace_dir,
            }
        else
            config.cmd = {
                'java',
                '-Declipse.application=org.eclipse.jdt.ls.core.id1',
                '-Dosgi.bundles.defaultStartLevel=4',
                '-Declipse.product=org.eclipse.jdt.ls.core.product',
                '-Dlog.protocol=true',
                '-Dlog.level=ALL',
                '-Xms1g',
                '--add-modules=ALL-SYSTEM',
                '--add-opens', 'java.base/java.util=ALL-UNNAMED',
                '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
                '-javaagent:' .. lombok_jar,
                '-Xbootclasspath/a:' .. lombok_jar,
                '-jar', vim.fn.glob(mason_pkg_path .. '/jdtls/plugins/org.eclipse.equinox.launcher_*.jar'),
                '-configuration', mason_pkg_path .. '/jdtls/config_' .. vim.loop.os_uname().sysname:lower(),
                '-data', workspace_dir,
            }
        end

        -- if the java runtimes are configured merge them into the config
        local runtimes = vim.tbl_get(my.sys_local, 'java', 'runtimes')
        if runtimes and not vim.tbl_isempty(runtimes) then
            config = vim.tbl_deep_extend('force', config, {
                settings = {
                    java = {
                        configuration = { runtimes = runtimes }
                    }
                }
            })
        end

        -- setup bundles for debug adapter protocol
        if mason_registry.is_installed('java-debug-adapter') then
            local debug_bundles = {
                vim.fn.glob(mason_pkg_path .. '/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar')
            }

            if mason_registry.is_installed('java-test') then
                vim.list_extend(debug_bundles, vim.split(vim.fn.glob(mason_pkg_path .. '/java-test/extension/server/*.jar'), '\n'))
            end

            config.init_options = { bundles = debug_bundles }
        end

        jdtls.start_or_attach(config)
    end
end

return {
    start = start
}
