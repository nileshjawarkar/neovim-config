require("commands.mvn")

local sys = require("core.util.sys")

-- Auto command to clear block cursor after exit. It help to prevent messup in terminals
-- color theme. This is useful in alacrity teminal OR may also helful in other
-- terminals.
vim.api.nvim_create_autocmd("ExitPre", {
    group = vim.api.nvim_create_augroup("Exit", { clear = true }),
    command = "set guicursor=a:ver90",
    desc = "Set cursor back to beam when leaving Neovim."
})

-- User commands
vim.api.nvim_create_user_command("JavaVersion", function()
    local v, err = require("core.rt.java").get_java_version()
    if err == nil and v ~= nil then
        print("Java version [" .. v.major .. "." .. v.minor .. "." .. v.patch .. "]")
    end
end, {})

vim.api.nvim_create_user_command("PrjInitConfig", function()
    local cur_dir = vim.fn.getcwd()
    sys.create_project_config(cur_dir)
end, {})

vim.api.nvim_create_user_command("PrjReloadConfig", function()
    local config = require("config.ws")
    config.reload_config()
end, {})

