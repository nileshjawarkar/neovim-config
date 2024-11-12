return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-live-grep-args.nvim" , version = "^1.0.0", },
    },
    config = function()
        local actions = require("telescope.actions")
        require("telescope").setup({
            defaults = {
                prompt_prefix = " > ",
                mappings = {
                    i = {
                        ["jk"] = actions.close,
                        ["C-q"] = actions.send_selected_to_qflist + actions.open_qflist,
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

        local telescope = require("telescope")
        telescope.load_extension("live_grep_args")

        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Fuzzy find files [<Leader>/]" })
        vim.keymap.set("n", "<leader>/", builtin.find_files, { desc = "Fuzzy find files" })

        vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "List open files [<Leader>Tab]" })
        -- vim.keymap.set("n", "<leader>,", builtin.buffers, { desc = "List open files" })
        vim.keymap.set("n", "<leader><Tab>", builtin.buffers, { desc = "List open files" })

        vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Find recent open files" })
        -- vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Find text" })
        vim.keymap.set("n", "<leader>fg", telescope.extensions.live_grep_args.live_grep_args, { desc = "Find text" })
        vim.keymap.set("n", "<leader>fw", function()
            builtin.grep_string({ search_dirs = { vim.fn.expand('%:p'), } })
        end, { desc = "Find text under cursor (in current buffer)" })
        vim.keymap.set("n", "<leader>fW", builtin.grep_string, { desc = "Find text under cursor (in workspace)" })

        vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Show help tags" })

        vim.keymap.set("n", "<leader>f.", builtin.current_buffer_fuzzy_find,
            { desc = "Fuzzy find in current file [<Leader>.]" })
        vim.keymap.set("n", "<leader>.", builtin.current_buffer_fuzzy_find, { desc = "Fuzzy find in current file" })
    end,
}
