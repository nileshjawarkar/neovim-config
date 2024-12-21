local jdtls = require("jdtls")
local jdtls_util = require("config.jdtls.util")
local sys = require("core.util.sys")

local on_attach = function(_, bufnr)
    -- Filetype-specific keymaps (these can be done in the ftplugin directory instead if you prefer)
    local keymap = vim.keymap
    keymap.set("n", "<leader>lo", jdtls.organize_imports,
        { noremap = true, silent = true, buffer = bufnr, desc = "Organize imports (gO)" })
    keymap.set("n", "gO", jdtls.organize_imports,
        { noremap = true, silent = true, buffer = bufnr, desc = "Organize imports" })
    keymap.set("n", "<leader>lu", jdtls.update_projects_config,
        { noremap = true, silent = true, buffer = bufnr, desc = "Update project config" })
    keymap.set("n", "<leader>le", jdtls.extract_variable,
        { noremap = true, silent = true, buffer = bufnr, desc = "Extract variable" })
    keymap.set("n", "<leader>lE", jdtls.extract_constant,
        { noremap = true, silent = true, buffer = bufnr, desc = "Extract constant" })
    keymap.set("v", "<leader>lm", [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
        { noremap = true, silent = true, buffer = bufnr, desc = "Extract method" })

    -- For debugging & running Unit tests
    -------------------------------------------
    -- 1) Define keymaps :
    keymap.set("n", "<leader>tc", jdtls.test_class,
        { noremap = true, silent = true, buffer = bufnr, desc = "All class tests" })
    keymap.set("n", "<leader>tt", jdtls.test_nearest_method,
        { noremap = true, silent = true, buffer = bufnr, desc = "Current test" })

    -- 2) Init
    jdtls_util.setup_dap()
end


local prepare_config = (function()
    -- Things that need to executed only once
    ----------------------------------------
    jdtls_util.rm_jdtls_ws()
    local root_dir = sys.find_root()
    jdtls_util.find_src_paths(root_dir, false, false)

    -- actual config preparation method
    ----------------------------------
    return function()
        local jdtls_options = jdtls_util.get_jdtls_options()
        local src_paths = jdtls_util.find_src_paths(nil, true, false)
        -- Get the default extended client capablities of the JDTLS language server
        -- Modify one property called resolveAdditionalTextEditsSupport and set it to true
        local extendedClientCapabilities = jdtls.extendedClientCapabilities
        extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
        local java, _ = jdtls_util.get_java_path()
        return {
            on_attach = on_attach,
            cmd = {
                java,
                '-Declipse.application=org.eclipse.jdt.ls.core.id1',
                '-Dosgi.bundles.defaultStartLevel=4',
                '-Declipse.product=org.eclipse.jdt.ls.core.product',
                '-Dlog.protocol=true',
                '-Dlog.level=ALL',
                '-Xms700m',
                '-Xmx4g',
                '--add-modules=ALL-SYSTEM',
                '--add-opens', 'java.base/java.util=ALL-UNNAMED',
                '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
                '-jar', jdtls_options.launcher,
                '-configuration', jdtls_options.configuration,
                '-Dosgi.sharedConfiguration.area=' .. jdtls_options.configuration,
                '-Dosgi.sharedConfiguration.area.readOnly=true',
                '-data', jdtls_options.project_dir,
            },
            root_dir = root_dir,
            settings = {
                java = {
                    -- home = vim.fn.getenv("JAVA_HOME"),
                    eclipse = { downloadSources = true, },
                    maven = { downloadSources = true, },
                    configuration = { updateBuildConfiguration = "interactive", },
                    implementationsCodeLens = { enabled = false, },
                    referencesCodeLens = { enabled = false, },
                    references = { enabled = false, },
                    signatureHelp = { enabled = true },
                    format = { enabled = true, },
                    contentProvider = { preferred = "fernflower" },
                    project = {
                        sourcePaths = src_paths,
                    },
                    cleanup = {
                        actions = {
                            -- "qualifyStaticMembers",
                            "addOverride", "addDeprecated",
                            "stringConcatToTextBlock", "invertEquals",
                            "addFinalModifier",
                        },
                    },
                    saveActions = { organizeImports = true, cleanup = true, },
                    completion = {
                        favoriteStaticMembers = {
                            "junit.Assert.*",
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
                            "#java", "java",
                            "#javax", "javax",
                            "#jakarta", "jakarta",
                            "#org", "org",
                            "#com", "com",
                        },
                    },
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
                        hashCodeEquals = { useJava7Objects = true, },
                        useBlocks = true,
                    },
                    inlayHints = {
                        parameterNames = { enabled = "all" }
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
                bundles = jdtls_options.dap_bundles,
                extendedClientCapabilities = extendedClientCapabilities,
            },
        }
    end
end)()

local setup_user_cmd = function()
    vim.api.nvim_create_user_command("DapPrintSrcPath", function()
        local paths = require("config.jdtls").find_src_paths(nil, true, false)
        require("core.util.table").dump(paths)
    end, {})
end

return {
    setup = function()
        if sys.first_time("jdtls_init") then
            setup_user_cmd()
        end
        jdtls.start_or_attach(prepare_config())
    end,
    get_java_path = jdtls_util.get_java_path,
    get_java_version = jdtls_util.get_java_version,
    find_src_paths = jdtls_util.find_src_paths,
    find_root = sys.find_root,
}
