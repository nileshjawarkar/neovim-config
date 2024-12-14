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
    local v, err = require("config.jdtls").get_java_version()
    if err == nil and v ~= nil then
        print("Java version [" .. v.major .. "." .. v.minor .. "." .. v.patch .. "]")
    end
end, {})

vim.api.nvim_create_user_command("InitPrjConfig", function()
    local cur_dir = vim.fn.getcwd()
    sys.create_project_config(cur_dir)
end, {})


vim.api.nvim_create_user_command("MvnCreateJavaProject", function()
    local cur_dir = vim.fn.getcwd()
    local mvn = require("config.jdtls.maven")
    if cur_dir ~= nil and mvn ~= nil then
        mvn:create_prj("java", cur_dir)
    end
end, {})

vim.api.nvim_create_user_command("MvnCreateJavaEEProject", function()
    local cur_dir = vim.fn.getcwd()
    local mvn = require("config.jdtls.maven")
    if cur_dir ~= nil and mvn ~= nil then
        mvn:create_prj("javaee", cur_dir)
    end
end, {})
