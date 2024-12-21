return {
    "nvim-telescope/telescope.nvim",
    event = 'VimEnter',
    branch = "0.1.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        { -- If encountering errors, see telescope-fzf-native README for installation instructions
            'nvim-telescope/telescope-fzf-native.nvim',
            build = 'make',
            cond = function()
                return vim.fn.executable 'make' == 1
            end,
        },
        { "nvim-telescope/telescope-live-grep-args.nvim", version = "^1.0.0", },
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

        -- Enable Telescope extensions if they are installed
        pcall(require('telescope').load_extension, 'live_grep_args')
        pcall(require('telescope').load_extension, 'fzf')

        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Fuzzy find files [<Leader>/]" })
        vim.keymap.set("n", "<leader>/", builtin.find_files, { desc = "Fuzzy find files" })

        vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "List open files [<Leader>Tab]" })
        vim.keymap.set("n", "<leader>,", builtin.buffers, { desc = "List open files" })

        vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Find recent open files" })
        -- vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Find text" })
        vim.keymap.set("n", "<leader>fg", require('telescope').extensions.live_grep_args.live_grep_args,
            { desc = "Find text" })
        vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Show help tags" })

        vim.keymap.set("n", "<leader>f.", builtin.current_buffer_fuzzy_find, { desc = "Find text (in current buffer)" })
        vim.keymap.set("n", "<leader>fW", builtin.grep_string, { desc = "Find text under cursor (in workspace)" })
        vim.keymap.set("n", "<leader>fw", function()
            builtin.grep_string({ search_dirs = { vim.fn.expand('%:p'), } })
        end, { desc = "Find text under cursor (in current buffer)" })
    end,
}
