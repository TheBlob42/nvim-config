local status_ok, jdtls, servers, dap = my.req('jdtls', 'nvim-lsp-installer.servers', 'dap')
if not status_ok then
    return
end

-- check if the java debug path is configured
local debug_path = my.lookup(my, { 'sys_local', 'java', 'debug', 'java_debug_path' })

local function jdtls_on_attach(client, bufnr)
    require('lsp.handlers').on_attach(client, bufnr)

    -- initialize dap for jdtls
    if debug_path then
        jdtls.setup_dap { hotcodereplace = 'auto' }
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
    end

    -- add JDTLS specific commands
    require('jdtls.setup').add_commands()

    -- add JDTLS specific keybindings
    vim.keymap.set('n', '<localleader>i', jdtls.organize_imports, { buffer = bufnr, desc = 'organize imports' })
end

local function start()
    local server_available, jdtls_server = servers.get_server("jdtls")
    if server_available then
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
            capabilities = require('lsp.handlers').make_capabilities(),
            on_attach = jdtls_on_attach,
            flags = {
                allow_incremental_sync = true,
            },
        }

        -- configure the server cmd (via `nvim-lsp-installer`)
        -- https://github.com/williamboman/nvim-lsp-installer/issues/501#issuecomment-1050664641
        jdtls_server:get_default_options().on_new_config(config, root_dir)

        -- setup bundles for debug adapter protocol
        if debug_path then
            config.init_options = {
                bundles = {
                    vim.fn.glob(debug_path .. '/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar')
                }
            }
        end

        jdtls.start_or_attach(config)
    end
end

return {
    start = start
}
