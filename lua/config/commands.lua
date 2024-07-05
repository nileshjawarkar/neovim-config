vim.api.nvim_create_user_command("JavaVersion", function()
    local v, err = require("config.jdtls").get_java_version()
    if err == nil and v ~= nil then
        print("Java version [" .. v.major .. "." .. v.minor .. "." .. v.patch .. "]")
    end
end, {})
