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
    local rt_java = require("core.rt.java")
    if rt_java ~= nil then
        local v, err = rt_java.get_java_version()
        if err == nil and v ~= nil then
            vim.notify("Java version [" .. v.major .. "." .. v.minor .. "." .. v.patch .. "]", vim.log.levels.INFO)
        end
    end
end, {})

vim.keymap.set("n", "<leader>Mi", function()
    local sys = require("core.util.sys")
    if sys ~= nil then
        sys.create_project_config(sys.get_cwd())
    end
end, { desc = "Init project with .nvim/init.lua" })

vim.keymap.set("n", "<leader>ML", function()
    local config = require("config.ws")
    if config ~= nil then
        config.reload_config()
    end
end, { desc = "Reload project config" })

vim.keymap.set("n", "<leader>Mp", function()
    local cur_dir = require("core.util.sys").get_cwd()
    local mvn = require("core.mvn")
    if cur_dir ~= nil and mvn ~= nil then
        mvn:createMM_prj(cur_dir, "JAVA")
    end
end, { desc = "Create java project" })

vim.keymap.set("n", "<leader>MP", function()
    local cur_dir = require("core.util.sys").get_cwd()
    local mvn = require("core.mvn")
    if cur_dir ~= nil and mvn ~= nil then
        mvn:createMM_prj(cur_dir, "JEE")
    end
end, { desc = "Create JavaEE project" })
