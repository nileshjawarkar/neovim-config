local keymap = vim.keymap
local jdtls = require("jdtls")

-- Filetype-specific keymaps (these can be done in the ftplugin directory instead if you prefer)
keymap.set("n", "<leader>go", function()
	if vim.bo.filetype == "java" then
		jdtls.organize_imports()
	end
end, { desc = "Organize imports" })

keymap.set("n", "<leader>gu", function()
	if vim.bo.filetype == "java" then
		jdtls.update_projects_config()
	end
end, { desc = "Update project config" })
