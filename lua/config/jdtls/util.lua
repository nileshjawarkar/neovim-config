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

local find_src_paths = (function()
    local paths = {}
    return function(input_dir, return_existing, reset)
        if return_existing ~= nil and return_existing == true then return paths end
        if reset ~= nil and reset == true then
            paths = {}
        end
        if input_dir ~= nil then
            local sys = require("core.util.sys")
            local is_mvn_prj = sys.is_file(input_dir .. "/" .. "pom.xml")
            scan_dir_for_src(input_dir, paths, is_mvn_prj, 1)
        end
        return paths
    end
end)()

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

local function get_java_version()
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
end

local setup_dap = (function()
    local init = false
    return function()
        local jdtls_dap = require('jdtls.dap')
        jdtls_dap.setup_dap_main_class_configs()
        vim.lsp.codelens.refresh()
        if init == false then
            jdtls_dap.setup_dap()
            init = true
        end
    end
end)()

return {
    get_java_path = get_java_path,
    get_java_version = get_java_version,
    get_jdtls_options = get_jdtls_options,
    rm_jdtls_ws = rm_jdtls_ws,
    find_src_paths = find_src_paths,
    find_root = find_root,
    setup_dap = setup_dap,
}
