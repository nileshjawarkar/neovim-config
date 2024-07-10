-- Auto command to clear block cursor after exit. It help to prevent messup in terminals 
-- color theme. This is useful in alacrity teminal OR may also helful in other
-- terminals.
vim.api.nvim_create_autocmd("ExitPre", {
	group = vim.api.nvim_create_augroup("Exit", { clear = true }),
	command = "set guicursor=a:ver90",
	desc = "Set cursor back to beam when leaving Neovim."
})

-- User commands
vim.api.nvim_create_user_command("DapResetSrcPath", function()
    require("config.jdtls").find_src_paths(nil, false, true)
end, {})

vim.api.nvim_create_user_command("DapPrintSrcPath", function()
    local paths = require("config.jdtls").find_src_paths(nil, true, false)
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

vim.api.nvim_create_user_command("DapInitPPSrcPath", function()
    local parentdir = vim.fn.fnamemodify( vim.fn.getcwd() .. "/../../", ':p:h')
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
