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

    local mason_share = data_path .. "/mason/share"
    local javaagent = mason_share .. "/jdtls/lombok.jar"
    local launcher = vim.fn.glob(mason_share .. "/jdtls/plugins/org.eclipse.equinox.launcher_*.jar")
    local configuration = data_path .. "/mason/packages/jdtls/" .. jdtls_config

    -- Needed for debugging
    local bundles = {
        vim.fn.glob(mason_share .. "/java-debug-adapter/com.microsoft.java.debug.plugin.jar"),
    }

    -- Needed for running/debugging unit tests
    vim.list_extend(bundles, vim.split(vim.fn.glob(mason_share .. "/java-test/*.jar", true), "\n"))

    -- require("core.util.table").dump(bundles)
    return {
        project_dir = workspace_dir,
        javaagent = javaagent,
        launcher = launcher,
        configuration = configuration,
        dap_bundles = bundles,
    }
end

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
