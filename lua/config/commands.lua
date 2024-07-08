
vim.api.nvim_create_user_command("DapResetSrcPath", function()
    require("config.jdtls").find_src_paths(nil, false, true)
end, {})

vim.api.nvim_create_user_command("DapInitSrcPath", function()
    local paths = require("config.jdtls").find_src_paths(vim.fn.getcwd(), false, true)
    for _, p in ipairs(paths) do
        print(p)
    end
end, {})

vim.api.nvim_create_user_command("DapInitParentSrcPath", function()
    local parentdir = vim.fn.fnamemodify( vim.fn.getcwd() .. "/../", ':p:h')
    local paths = require("config.jdtls").find_src_paths(parentdir, false, true)
    for _, p in ipairs(paths) do
        print(p)
    end
end, {})

vim.api.nvim_create_user_command("JavaVersion", function()
    local v, err = require("config.jdtls").get_java_version()
    if err == nil and v ~= nil then
        print("Java version [" .. v.major .. "." .. v.minor .. "." .. v.patch .. "]")
    end
end, {})
