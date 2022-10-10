local jdtls = require('jdtls')
local dap = require('dap')

-- use to check if jdtls, java-debug-adapter & java-test are installed
local mason_registry = require('mason-registry')
local mason_pkg_path = require('mason.settings').current.install_root_dir .. '/packages'

local lombok_jar = mason_pkg_path .. '/jdtls/lombok.jar'

---Return lombok "javaagent" parameter for the usage with the "jdtls" python script
---@return string
local function get_lombok_javaagent()
    if vim.loop.fs_stat(lombok_jar) then
        return '--jvm-arg=-javaagent:' .. lombok_jar
    end
    return ''
end

---Return lombok "bootclasspath" parameter for the usage with the "jdtls" python script
---@return string
local function get_lombok_bootclasspath()
    if vim.loop.fs_stat(lombok_jar) then
        return '--jvm-arg=-Xbootclasspath/a:' .. lombok_jar
    end
    return ''
end

local function jdtls_on_attach(client, bufnr)
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
        local root_dir = require('jdtls.setup').find_root({ 'gradlew', '.git', 'pom.xml', 'mvnw' })

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
            flags = {
                allow_incremental_sync = true,
            },

            -- requires python version 3.9 for the 'jdtls' script
            cmd = {
                'jdtls',
                '-configuration', vim.fn.stdpath('data') .. '/mason/packages/jdtls/config_' .. vim.loop.os_uname().sysname:lower(),
                get_lombok_javaagent(),
                get_lombok_bootclasspath(),
                '-data', '/home/tobi/workspace/' .. vim.fn.fnamemodify(root_dir, ':p:h:t'),
            },

            -- "oldschool" style of starting jdtls
            -- cmd = {
            --     'java',
            --     '-Declipse.application=org.eclipse.jdt.ls.core.id1',
            --     '-Dosgi.bundles.defaultStartLevel=4',
            --     '-Declipse.product=org.eclipse.jdt.ls.core.product',
            --     '-Dlog.protocol=true',
            --     '-Dlog.level=ALL',
            --     '-Xms1g',
            --     '--add-modules=ALL-SYSTEM',
            --     '--add-opens', 'java.base/java.util=ALL-UNNAMED',
            --     '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
            --     '-javaagent', '<path to lombok.jar>',
            --     '-Xbootclasspath/a', '<path to lombok.jar>',
            --     '-jar', vim.fn.glob(vim.fn.stdpath('data') .. '/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar'),
            --     '-configuration', vim.fn.stdpath('data') .. '/mason/packages/jdtls/config_' .. vim.loop.os_uname().sysname:lower(),
            --     '-data', '/home/tobi/workspace/' .. vim.fn.fnamemodify(root_dir, ':p:h:t'),
            -- },
        }

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
