return {
	"mhartington/formatter.nvim",
	config = function()
		-- local util = require "formatter.util"
		require("formatter").setup({
			logging = true,
			log_level = vim.log.levels.WARN,
			filetype = {
				lua = {
					require("formatter.filetypes.lua").stylua,
				},

				c = {
					{
						exe = "clang-format",
						args = { "--style=Microsoft" },
						stdin = true,
					},
				},

				cpp = {
					{
						exe = "clang-format",
						args = { "--style=Microsoft" },
						stdin = true,
					},
				},

				java = {
					{
						exe = "clang-format",
						args = { '--style="{BasedOnStyle: Google, IndentWidth: 4}"', "--assume-filename=.java" },
						stdin = true,
					},
				},

				json = {
					require("formatter.filetypes.json").prettier,
				},

				yaml = {
					require("formatter.filetypes.yaml").prettier,
				},

				javascript = {
					require("formatter.filetypes.javascript").prettier,
				},

				typescript = {
					require("formatter.filetypes.typescript").prettier,
				},

				html = {
					require("formatter.filetypes.html").prettier,
				},

				css = {
					require("formatter.filetypes.css").prettier,
				},

				markdown = {
					require("formatter.filetypes.markdown").prettier,
				},

				["*"] = {
					require("formatter.filetypes.any").remove_trailing_whitespace,
				},
			},
		})

		vim.keymap.set("n", "<leader>F", "<cmd>Format<CR>", {desc = "Format code"})
	end,
}
