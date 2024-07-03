local home = vim.fn.getenv("JAVA_HOME")
if home == nil then
    print("Please define environment variable \'JAVA_HOME\'");
    return
end

local jdtls = require('jdtls')

local function get_jdtls_options()
    local data_path = vim.fn.stdpath("data")
    local sys = require("core.util.sys")
    local project_name = sys.get_cur_dir()
    local os_name = sys.get_os()
    local workspace_dir = data_path .. '/workspace/jdtls/' .. project_name

    local jdtls_config = "config_mac"
    if os_name == "Linux" then
        jdtls_config = "config_linux"
    elseif os_name == "Windows" then
        jdtls_config = "config_win"
    end

    local javaagent = data_path .. "/mason/share/jdtls/lombok.jar"
    local launcher = vim.fn.glob(data_path .. "/mason/share/jdtls/plugins/org.eclipse.equinox.launcher_*.jar")
    local configuration = data_path .. '/mason/packages/jdtls/' .. jdtls_config
    return {
        project_dir = workspace_dir,
        javaagent = javaagent,
        launcher = launcher,
        configuration = configuration,
    }
end

local on_attach = function(_, bufnr)
    -- Filetype-specific keymaps (these can be done in the ftplugin directory instead if you prefer)
    local keymap = vim.keymap
    keymap.set("n", "<leader>go", jdtls.organize_imports,
        { noremap = true, silent = true, buffer = bufnr, desc = "Organize imports" })
    keymap.set("n", "gO", jdtls.organize_imports,
        { noremap = true, silent = true, buffer = bufnr, desc = "Organize imports" })
    keymap.set("n", "<leader>gu", jdtls.update_projects_config,
        { noremap = true, silent = true, buffer = bufnr, desc = "Update project config" })
    keymap.set("n", "<leader>ge", jdtls.extract_variable,
        { noremap = true, silent = true, buffer = bufnr, desc = "Extract variable" })
    keymap.set("n", "<leader>gE", jdtls.extract_constant,
        { noremap = true, silent = true, buffer = bufnr, desc = "Extract constant" })
    keymap.set("v", "<leader>gm", [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
        { noremap = true, silent = true, buffer = bufnr, desc = "Extract method" })

    -- For debugging & running Unit tests
    -------------------------------------------
    -- 1) Define keymaps :
    -- keymap.set("n", "<leader>jc", jdtls.test_class,
    --     { noremap = true, silent = true, buffer = bufnr, desc = "Test class" })
    -- keymap.set("n", "<leader>jm", jdtls.test_nearest_method,
    --     { noremap = true, silent = true, buffer = bufnr, desc = "Test nearest method" })

    -- Need review of the following key defs:
    -------------------------------------------
    -- keymap.set("n", "<leader>bb", "<cmd>lua require'dap'.toggle_breakpoint()<cr>")
    -- keymap.set("n", "<leader>bc", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>")
    -- keymap.set("n", "<leader>bl", "<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<cr>")
    -- keymap.set("n", '<leader>br', "<cmd>lua require'dap'.clear_breakpoints()<cr>")
    -- keymap.set("n", '<leader>ba', '<cmd>Telescope dap list_breakpoints<cr>')
    -- keymap.set("n", "<leader>dc", "<cmd>lua require'dap'.continue()<cr>")
    -- keymap.set("n", "<leader>dj", "<cmd>lua require'dap'.step_over()<cr>")
    -- keymap.set("n", "<leader>dk", "<cmd>lua require'dap'.step_into()<cr>")
    -- keymap.set("n", "<leader>do", "<cmd>lua require'dap'.step_out()<cr>")
    -- keymap.set("n", '<leader>dd', function() require('dap').disconnect(); require('dapui').close(); end)
    -- keymap.set("n", '<leader>dt', function() require('dap').terminate(); require('dapui').close(); end)
    -- keymap.set("n", "<leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>")
    -- keymap.set("n", "<leader>dl", "<cmd>lua require'dap'.run_last()<cr>")
    -- keymap.set("n", '<leader>di', function() require "dap.ui.widgets".hover() end)
    -- keymap.set("n", '<leader>d?', function() local widgets = require "dap.ui.widgets"; widgets.centered_float(widgets.scopes) end)
    -- keymap.set("n", '<leader>df', '<cmd>Telescope dap frames<cr>')
    -- keymap.set("n", '<leader>dh', '<cmd>Telescope dap commands<cr>')
    -- keymap.set("n", '<leader>de', function() require('telescope.builtin').diagnostics({default_text=":E:"}) end)

    -- 2) Init
    -- jdtls.setup_dap({ hotcodereplace = 'auto' })
    -- require('jdtls.dap').setup_dap_main_class_configs()
end

local config = (function()
    local jdtls_options = get_jdtls_options()

    -- Get the default extended client capablities of the JDTLS language server
    -- Modify one property called resolveAdditionalTextEditsSupport and set it to true
    local extendedClientCapabilities = jdtls.extendedClientCapabilities
    extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

    return {
        on_attach = on_attach,
        cmd = {
            'java',
            '-Declipse.application=org.eclipse.jdt.ls.core.id1',
            '-Dosgi.bundles.defaultStartLevel=4',
            '-Declipse.product=org.eclipse.jdt.ls.core.product',
            '-Dlog.protocol=true',
            '-Dlog.level=ALL',
            '-javaagent:' .. jdtls_options.javaagent,
            '-Xmx4g',
            '--add-modules=ALL-SYSTEM',
            '--add-opens', 'java.base/java.util=ALL-UNNAMED',
            '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
            '-jar', jdtls_options.launcher,
            '-configuration', jdtls_options.configuration,
            '-data', jdtls_options.project_dir
        },

        root_dir = require('jdtls.setup').find_root({ '.git', 'mvnw', 'pom.xml', 'build.gradle' }),
        settings = {
            java = {
                -- home = vim.fn.getenv("JAVA_HOME"),
                eclipse = { downloadSources = true, },
                maven = { downloadSources = true, },
                configuration = {
                    updateBuildConfiguration = "interactive",
                },
                implementationsCodeLens = {
                    enabled = true,
                },
                referencesCodeLens = {
                    enabled = true,
                },
                references = {
                    includeDecompiledSources = false,
                },
                signatureHelp = { enabled = true },
                format = { enabled = true, },
                contentProvider = {
                    preferred = "fernflower"
                },
                saveActions = {
                    organizeImports = true
                },
                completion = {
                    favoriteStaticMembers = {
                        "org.hamcrest.MatcherAssert.assertThat",
                        "org.hamcrest.Matchers.*",
                        "org.hamcrest.CoreMatchers.*",
                        "org.junit.jupiter.api.Assertions.*",
                        "org.mockito.Mockito.*",
                    },
                    filteredTypes = {
                        "com.sun.*",
                        "io.micrometer.shaded.*",
                        "sun.*",
                    },
                    importOrder = {
                        "java",
                        "javax",
                        "jakarta",
                        "org",
                        "com",
                    },
                },
                extendedClientCapabilities = extendedClientCapabilities,
                sources = {
                    organizeImports = {
                        starThreshold = 9999,
                        staticStarThreshold = 9999,
                        staticThreshold = 9999,
                    },
                },
                codeGeneration = {
                    toString = {
                        template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                    },
                    hashCodeEquals = {
                        useJava7Objects = true,
                    },
                    useBlocks = true,
                },
                inlayHints = {
                    parameterNames = {
                        enabled = "all"
                    }
                }
            },
        },
        -- Needed for auto-completion with method signatures and placeholders
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
        flags = {
            debounce_text_changes = 90,
            allow_incremental_sync = true,
        },
        init_options = {
            -- bundles = bundles,
            extendedClientCapabilities = extendedClientCapabilities,
        },
    }
end)()


-- This starts a new client & server, or attaches to an existing client & server based on the `root_dir`.
jdtls.start_or_attach(config)
