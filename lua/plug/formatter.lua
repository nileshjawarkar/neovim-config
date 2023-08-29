return {
	"mhartington/formatter.nvim",
	config = function()
		-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
		require("formatter").setup({
			-- Enable or disable logging
			logging = true,
			-- Set the log level
			log_level = vim.log.levels.WARN,
			-- All formatter configurations are opt-in
			filetype = {
				-- c = {
				-- 	require("formatter.filetypes.c").clangformat,
				-- },
				-- cpp = {
				-- 	require("formatter.filetypes.cpp").clangformat,
				-- },
				lua = {
					require("formatter.filetypes.lua").stylua,
				},

				-- Use the special "*" filetype for defining formatter configurations on
				-- any filetype
				["*"] = {
					-- "formatter.filetypes.any" defines default configurations for any
					-- filetype
					require("formatter.filetypes.any").remove_trailing_whitespace,
				},
			},
		})

		vim.keymap.set("n", "<leader>ft", "<cmd>Format<CR>", {})
	end,
}
