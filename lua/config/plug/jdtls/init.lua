local jdtls = require("jdtls")
local jdtls_util = require("config.plug.jdtls.util")
local mvn_util = require("core.mvn")
local sys = require("core.util.sys")
local first_time = sys.first_time

local on_attach = function(_, bufnr)
    -- Filetype-specific keymaps (these can be done in the ftplugin directory instead if you prefer)
    local function keymap(m, key, handler, desc)
        vim.keymap.set(m, key, handler, { noremap = true, buffer = bufnr, silent = true, desc = desc })
    end

    keymap("n", "<leader>lo", jdtls.organize_imports, "Organize imports")
    keymap("n", "<leader>lu", jdtls.update_projects_config, "Update project config")
    keymap("n", "<leader>le", jdtls.extract_variable, "Extract variable")
    keymap("n", "<leader>lE", jdtls.extract_constant, "Extract constant")
    keymap("v", "<leader>lm", [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]], "Extract method")

    -- For debugging & running Unit tests
    keymap("n", "<leader>tc", jdtls.test_class, "All class tests")
    keymap("n", "<leader>tt", jdtls.test_nearest_method, "Current test")

    if first_time.check("jdtls_dap_init") then
        -- Use WS/.nvim/config.lua for defining the debug configurations
        local jdtls_dap = require('jdtls.dap')
        if jdtls_dap ~= nil then
            require("config.plug.dap.java").set_defaults()
            jdtls_dap.setup_dap({ hotcodereplace = "auto" })
            first_time.setFalse("jdtls_dap_init")
        end
    end
end


local prepare_config = (function()
    -- Things that need to executed only once
    ----------------------------------------
    local jdtls_options = jdtls_util.get_jdtls_options()
    jdtls_util.rm_jdtls_ws()
    local root_dir = sys.find_root()
    mvn_util.find_src_paths(root_dir, false, false)

    -- actual config preparation method
    ----------------------------------
    return function()
        local src_paths = mvn_util.find_src_paths(nil, true, false)
        -- Get the default extended client capablities of the JDTLS language server
        -- Modify one property called resolveAdditionalTextEditsSupport and set it to true
        local extendedClientCapabilities = jdtls.extendedClientCapabilities
        extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
        local java, _ = require("core.rt.java").get_java_path()
        return {
            on_attach = on_attach,
            cmd = {
                java,
                '-Declipse.application=org.eclipse.jdt.ls.core.id1',
                '-Dosgi.bundles.defaultStartLevel=4',
                '-Declipse.product=org.eclipse.jdt.ls.core.product',
                '-Dlog.protocol=true',
                '-Dlog.level=ALL',
                '-Xms500m',
                '-Xmx3g',
                '-javaagent:' .. jdtls_options.javaagent,
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
                debounce_text_changes = 110,
                allow_incremental_sync = true,
            },
            init_options = {
                bundles = jdtls_options.dap_bundles,
                extendedClientCapabilities = extendedClientCapabilities,
            },
        }
    end
end)()

local perform_checks = function()
    if not require("mason-registry").is_installed("jdtls") then
        return false
    end
    local version, err = require("core.rt.java").get_java_version()
    local jtls_err = "Error - Lsp server (jdtls) start failed."
    if err ~= nil then
        vim.notify(jtls_err .. " " .. err, vim.log.levels.INFO)
    elseif version == nil then
        vim.notify(jtls_err .. " Failed to retrieve java version.", vim.log.levels.INFO)
    elseif version.major < 17 then
        vim.notify("Error : Current java version \"" .. version.major .. "\", minimum required \"17\".",
            vim.log.levels.INFO)
    else
        return true
    end
    return false
end

local startReq = false
return {
    setup = function()
        if first_time.check("jdtls_init") then
            startReq = perform_checks()
            if startReq then
                vim.notify("Please wait. Lsp starting..", vim.log.levels.INFO)
                vim.api.nvim_create_user_command("DapPrintSrcPath", function()
                    local paths = require("core.mvn.util").find_src_paths(nil, true, false)
                    require("core.util.table").dump(paths)
                end, {})
            end
            first_time.setFalse("jdtls_init")
        end
        if startReq then jdtls.start_or_attach(prepare_config()) end
    end,
}
