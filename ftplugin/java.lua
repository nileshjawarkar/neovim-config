local jdtls = require('jdtls')
local data_path = vim.fn.stdpath("data")
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = data_path .. '/jdtls-workspace/' .. project_name

local home = vim.fn.getenv("JAVA_HOME")
if home == nil then
    print("Please define environment variable \'JAVA_HOME\'");
    return
end

-- decide config dir as per OS
local os_name = vim.loop.os_uname().sysname
local jdtls_config = "config_mac"
if os_name == "Linux" or string.find(os_name, "inux") then
    jdtls_config = "config_linux"
elseif os_name == "Windows_NT" or string.find(os_name, "indows") then
    jdtls_config = "config_win"
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

-- For debugging & running Unit tests
-------------------------------------------
-- 0) Setup class path:
-- Needed for debugging
-- local bundles = {
--     vim.fn.glob(data_path .. '/mason/share/java-debug-adapter/com.microsoft.java.debug.plugin.jar'),
-- }
-- Needed for running/debugging unit tests
-- vim.list_extend(bundles, vim.split(vim.fn.glob(data_path .. "/mason/share/java-test/*.jar", 1), "\n"))

local config = {
    on_attach = on_attach,
    cmd = {
        'java',
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-javaagent:' .. data_path .. '/mason/share/jdtls/lombok.jar',
        '-Xmx4g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens', 'java.base/java.util=ALL-UNNAMED',
        '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
        '-jar', data_path .. '/mason/share/jdtls/plugins/org.eclipse.equinox.launcher.jar',
        '-configuration', data_path .. '/mason/packages/jdtls/' .. jdtls_config,
        '-data', workspace_dir
    },

    root_dir = require('jdtls.setup').find_root({ '.git', 'mvnw', 'pom.xml', 'build.gradle' }),
    settings = {
        java = {
            home = vim.fn.getenv("JAVA_HOME"),
            eclipse = {
                downloadSources = true,
            },
            configuration = {
                updateBuildConfiguration = "interactive",
            },
            maven = {
                downloadSources = true,
            },
            implementationsCodeLens = {
                enabled = true,
            },
            referencesCodeLens = {
                enabled = true,
            },
            references = {
                includeDecompiledSources = true,
            },
            signatureHelp = { enabled = true },
            format = {
                enabled = true,
            },
        },
        completion = {
            favoriteStaticMembers = {
                "org.hamcrest.MatcherAssert.assertThat",
                "org.hamcrest.Matchers.*",
                "org.hamcrest.CoreMatchers.*",
                "org.junit.jupiter.api.Assertions.*",
                "java.util.Objects.requireNonNull",
                "java.util.Objects.requireNonNullElse",
                "org.mockito.Mockito.*",
            },
            importOrder = {
                "java",
                "javax",
                "jakarta",
                "com",
                "org",
            },
        },
        extendedClientCapabilities = jdtls.extendedClientCapabilities,
        sources = {
            organizeImports = {
                starThreshold = 9999,
                staticStarThreshold = 9999,
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
    },
    -- Needed for auto-completion with method signatures and placeholders
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
    flags = {
        debounce_text_changes = 90,
        allow_incremental_sync = true,
    },

    -- For debugging & running Unit tests
    -------------------------------------------
    -- Init :
    -- init_options = {
    --     bundles = bundles
    -- },
}

-- This starts a new client & server, or attaches to an existing client & server based on the `root_dir`.
jdtls.start_or_attach(config)
