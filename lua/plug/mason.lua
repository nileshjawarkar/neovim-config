return {
	"mason-org/mason.nvim",
	dependencies = {
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		require("mason").setup({
			PATH = "append",
			log_level = vim.log.levels.INFO,
			max_concurrent_installers = 8,
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "*",
				},
				check_outdated_packages_on_open = true,
				border = "rounded",
				width = 0.8,
				height = 0.8,
				keymaps = {
					toggle_package_expand = "<CR>",
					install_package = "i",
					update_package = "u",
					check_package_version = "c",
					update_all_packages = "U",
					check_outdated_packages = "C",
					uninstall_package = "x",
					cancel_installation = "<C-c>",
					apply_language_filter = "<C-f>",
				},
			},
		})
		require("mason-tool-installer").setup({
			ensure_installed = require("config.reqTools").mason_req,
			auto_update = false,
			run_on_start = true,
			start_delay = 3000, -- 3 second delay
			debounce_hours = 5, -- at least 5 hours between attempts to install/update
			-- By default all integrations are enabled. If you turn on an integration
			-- and you have the required module(s) installed this means you can use
			-- alternative names, supplied by the modules, for the thing that you want
			-- to install. If you turn off the integration (by setting it to false) you
			-- cannot use these alternative names. It also suppresses loading of those
			-- module(s) (assuming any are installed) which is sometimes wanted when
			-- doing lazy loading.
			integrations = {
				["mason-lspconfig"] = true,
				["mason-nvim-dap"] = true,
			},
		})
	end,
}
