vim.api.nvim_create_user_command("JavaVersion", function()
    local v = require("config.jdtls").get_java_version()
    print("Java " .. v.major .. "." .. v.minor .. "." .. v.patch)
end, {})
