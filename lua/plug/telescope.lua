return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local actions = require("telescope.actions")
		require("telescope").setup({
			defaults = {
				prompt_prefix = " > ",
				mappings = {
					i = {
						["jk"] = actions.close,
                        ["C-h"] = actions.move_selection_previous,
                        ["C-l"] = actions.move_selection_next,
                        ["C-q"] = actions.send_selected_to_qflist + actions.open_qflist
					},
				},
				set_env = { ["COLORTERM"] = "truecolor" },
				path_display = { truncate = 1 },
			},

			pickers = {
				find_files = {
					previewer = false,
					disable_devicons = true,
				},
				live_grep = {
					disable_devicons = true,
				},
				buffers = {
					sort_lastused = true,
					disable_devicons = true,
					previewer = false,
				},
			},
		})

		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files"})
		vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Find recent open files"})
		vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Find text" })
		vim.keymap.set("n", "<leader>fc", builtin.grep_string, { desc = "Find text under cursor" })
		vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "List open files" })
		vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Show help tags" })
	end,
}
