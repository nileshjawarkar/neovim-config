vim.api.nvim_create_user_command("MvnCreateJavaProject", function()
    local cur_dir = vim.fn.getcwd()
    local mvn = require("core.mvn")
    if cur_dir ~= nil and mvn ~= nil then
        -- mvn.create_prj("java", cur_dir)
        mvn:createMM_prj(cur_dir, "JAVA")
    end
end, {})

vim.api.nvim_create_user_command("MvnCreateJEEProject", function()
    local cur_dir = vim.fn.getcwd()
    local mvn = require("core.mvn")
    if cur_dir ~= nil and mvn ~= nil then
        -- mvn.create_prj("jee", cur_dir)
        mvn:createMM_prj(cur_dir, "JEE")
    end
end, {})
