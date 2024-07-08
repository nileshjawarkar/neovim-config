local jdtls = require('jdtls')
local function get_jdtls_options()
    local data_path = vim.fn.stdpath("data")
    local sys = require("core.util.sys")
    local project_name = sys.get_curdir_name()
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

    local mason_pkg = data_path .. "/mason/packages"
    local configuration = mason_pkg .. "/jdtls/" .. jdtls_config

    -- java dap
    local dap_bundles = {
        vim.fn.glob(mason_pkg .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar", true),
    }
    vim.list_extend(dap_bundles, vim.split(vim.fn.glob(mason_pkg .. "/java-test/extension/server/*.jar", true), "\n"))
    return {
        project_dir = workspace_dir,
        javaagent = javaagent,
        launcher = launcher,
        configuration = configuration,
        dap_bundles = dap_bundles,
    }
end

local setup_dap = (function()
    local init = false
    return function()
        vim.lsp.codelens.refresh()
        if init == false then
            local jdtls_dap = require('jdtls.dap')
            jdtls_dap.setup_dap()
            jdtls_dap.setup_dap_main_class_configs()
            init = true
        end
    end
end)()

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
    keymap.set("n", "<leader>jc", jdtls.test_class,
        { noremap = true, silent = true, buffer = bufnr, desc = "Class tests" })
    keymap.set("n", "<leader>jm", jdtls.test_nearest_method,
        { noremap = true, silent = true, buffer = bufnr, desc = "Current test" })

    -- 2) Init
    setup_dap()
end


local function rm_jdtls_ws()
    local data_path = vim.fn.stdpath("data")
    local sys = require("core.util.sys")
    local project_name = sys.get_curdir_name()
    sys.rm_rf(data_path .. '/workspace/jdtls/' .. project_name)
end

local function scan_dir_for_src(parent_dir, paths, is_mvn_prj, cur_level)
    -- To avoid searching above the max-dept. It will help when
    -- when current directory has huge directory depth. Any way we didnt expect sub-projects at
    -- depth gretor than 5.
    if cur_level > 5 then return end
    local file_names = vim.fn.readdir(parent_dir)
    if file_names == nil then return end
    for _, file in ipairs(file_names) do
        -- if list has any hidden directory, skip it.
        if string.len(file) > 0 and string.sub(file, 1, 1) ~= "." then
            local cur_file_path = parent_dir .. "/" .. file
            if 1 == vim.fn.isdirectory(cur_file_path) then
                -- directory name is src/SRC/Src and it to the
                -- output list
                if file == "src" then
                    local add_src = true
                    -- If this is maven project, we need to check if project has following structure.
                    -- If yes, add these following directories as src directory
                    -- ----------------------------------------------------------
                    -- src-+
                    --     |
                    --     +- main
                    --     |    |
                    --     +    +- java
                    --     |
                    --     +- test
                    --          |
                    --          +- java
                    -- In other cases, add src only
                    -- ----------------------------------------------------------
                    if is_mvn_prj == true then
                        if 1 == vim.fn.isdirectory(cur_file_path .. "/main/java") then
                            table.insert(paths, cur_file_path .. "/main/java")
                            add_src = false
                        end
                        if 1 == vim.fn.isdirectory(cur_file_path .. "/test/java") then
                            table.insert(paths, cur_file_path .. "/test/java")
                            add_src = false
                        end
                    end
                    if add_src == true then
                        table.insert(paths, cur_file_path)
                    end
                    -- Else cotinue search for src directory
                else
                    scan_dir_for_src(cur_file_path, paths, is_mvn_prj, cur_level + 1)
                end
            end
        end
    end
end

local function find_src_paths(cur_dir)
    local sys = require("core.util.sys")
    local paths = {}
    if cur_dir ~= nil then
        local is_mvn_prj = sys.is_file(cur_dir .. "/" .. "pom.xml")
        scan_dir_for_src(cur_dir, paths, is_mvn_prj, 1)
    end
    return paths
end

local function dir_has_any(dir, file_list)
    local files = vim.fn.readdir(dir)
    for _, f in ipairs(files) do
        for _, cf in ipairs(file_list) do
            if f == cf then
                return true
            end
        end
    end
    return false
end

local function find_root()
    local ws_files = { ".git", "pom.xml", "mvnw", "gradlew" }
    local cur_dir = vim.fn.getcwd()
    if true == dir_has_any(cur_dir, ws_files) then
        return cur_dir;
    else
        return vim.fs.root(0, ws_files)
    end
end

local prepare_config = (function()
    -- Things that need to executed only once
    ----------------------------------------
    rm_jdtls_ws()
    local root_dir = find_root()
    local src_paths = find_src_paths(root_dir)

    -- actual config preparation method
    ----------------------------------
    return function()
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
                '-Xmx3g',
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
                    implementationsCodeLens = { enabled = true, },
                    referencesCodeLens = { enabled = true, },
                    references = { includeDecompiledSources = false, },
                    signatureHelp = { enabled = true },
                    format = { enabled = true, },
                    contentProvider = { preferred = "fernflower" },
                    project = {
                        sourcePaths = src_paths,
                    },
                    cleanup = {
                        actionsOnSave = {
                            "qualifyMembers", "qualifyStaticMembers",
                            "addOverride", "addDeprecated",
                            "stringConcatToTextBlock", "invertEquals",
                            "addFinalModifier", "instanceofPatternMatch",
                            "lambdaExpression", "switchExpression"
                        }
                    },
                    saveActions = { organizeImports = true },
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

local function get_java_path()
    local java_home = os.getenv("JAVA_HOME")
    if java_home ~= nil then
        local sys = require("core.util.sys")
        if sys.is_dir(java_home) then
            return java_home .. "/bin/java", nil
        else
            return nil, "JAVA_HOME path \"" .. java_home .. "\" does not exist."
        end
    end
    return "java", nil
end

return {
    setup = function()
        jdtls.start_or_attach(prepare_config())
    end,
    get_java_path = get_java_path,
    get_java_version = function()
        local sys = require("core.util.sys")
        local version = { major = 0, minor = 0, patch = 0 }
        local java_path, err = get_java_path()
        if err ~= nil then
            return version, err
        end
        local r = sys.exec_r(java_path .. " -version 2>&1")
        if r ~= nil then
            for mv, sv, pv in string.gmatch(r, "[version]+%s+.(%d+)%.(%d+)%.(%d+).%s+") do
                local major, minor, patch = tonumber(mv), tonumber(sv), tonumber(pv)
                if major ~= nil and minor ~= nil then
                    version.major = major;
                    version.minor = minor;
                    version.patch = patch;
                    break
                end
            end
        else
            err = "Failed to read version using cmd \"" + java_path + " -version\""
        end
        return version, err
    end,
    find_src_paths = find_src_paths,
    find_root = find_root,
}
