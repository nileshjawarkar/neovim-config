local get_jdtls_options = (function()
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
    local jar_patterns = {
        "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
        "/java-test/extension/server/*.jar",
    }
    local bundles = {}
    for _, jar_pattern in ipairs(jar_patterns) do
        for _, bundle in ipairs(vim.split(vim.fn.glob(mason_pkg .. jar_pattern), '\n')) do
            if not vim.endswith(bundle, 'com.microsoft.java.test.runner-jar-with-dependencies.jar')
                and not vim.endswith(bundle, 'com.microsoft.java.test.runner.jar') then
                table.insert(bundles, bundle)
            end
        end
    end

    -- require("core.util.table").dump(bundles)
    return function()
        return {
            project_dir = workspace_dir,
            javaagent = javaagent,
            launcher = launcher,
            configuration = configuration,
            dap_bundles = bundles,
        }
    end
end)()

local function rm_jdtls_ws()
    local data_path = vim.fn.stdpath("data")
    local sys = require("core.util.sys")
    local project_name = sys.get_curdir_name()
    sys.rm_rf(data_path .. '/workspace/jdtls/' .. project_name)
end

return {
    get_jdtls_options = get_jdtls_options,
    rm_jdtls_ws = rm_jdtls_ws,
}
