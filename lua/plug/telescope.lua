return {
    "nvim-telescope/telescope.nvim",
    event = 'VimEnter',
    branch = "0.1.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        {
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
            extensions = {
                fzf = {},
            }
        })

        -- Enable Telescope extensions if they are installed
        pcall(require('telescope').load_extension, 'live_grep_args')
        pcall(require('telescope').load_extension, 'fzf')

        -- This function will close terminal, quick list, mason and lazy buffers
        -- before starting telescope.
        local function execute_checks_and_preqs()
            local buftype = vim.bo.filetype
            if buftype == "mason" or vim.bo.filetype == "lazy" then
                vim.cmd("bdelete")
            elseif buftype == "dapui_watches" or buftype == "dapui_scopes"
                or buftype == "dapui_stacks" or buftype == "dapui_console" then
                vim.notify("While in DAP, please use telescope from code buffer.", vim.log.levels.INFO)
                return false
            end
            require("core.nvim.handlers").close({ "term", "qf" })
            return true
        end

        -- This function will build the handlers function will call
        -- preq-check-exec function before calling telescope specific function.
        local function prepare_handler(fun, args)
            return function()
                if not execute_checks_and_preqs() then return end
                if args ~= nil then
                    fun(args())
                    return
                end
                fun()
            end
        end

        -- Define local key handlers
        local builtin = require("telescope.builtin")

        local find_diagnostics = prepare_handler(builtin.diagnostics)
        local resume = prepare_handler(builtin.resume)
        local find_files = prepare_handler(builtin.find_files)
        local show_buffers = prepare_handler(builtin.buffers)
        local show_recentfile = prepare_handler(builtin.oldfiles)
        local show_help = prepare_handler(builtin.help_tags)
        local fuzzy_find_tuc_in_ws = prepare_handler(builtin.grep_string)
        local live_grep = prepare_handler(require('telescope').extensions.live_grep_args.live_grep_args)
        local find_in_open_bufs = prepare_handler(function()
            builtin.live_grep {
                grep_open_files = true,
                prompt_title = 'Search in open files',
            }
        end)

        -- This need tobe a function not table to feed runtime value
        -- of current buffer.
        local function buf_search_op()
            return {
                search_dirs = { vim.fn.expand('%:p'), },
                prompt_title = 'Search in current file',
            }
        end
        local fuzzy_find_tuc_in_cur_buf = prepare_handler(builtin.grep_string, buf_search_op)
        local find_in_cur_buf = prepare_handler(builtin.live_grep, buf_search_op)

        -- Define key maps
        local function keymap(m, key, handler, desc)
            vim.keymap.set(m, key, handler, { noremap = true, silent = true, desc = desc })
        end

        keymap("n", "<leader>ff", find_files, "Fuzzy find files [<Leader><Leader>]")
        keymap("n", "<leader><leader>", find_files, "Fuzzy find files")
        keymap("n", "<leader>fR", show_recentfile, "Find recent open files")
        keymap("n", "<leader>fg", live_grep, "Find text")
        keymap("n", "<leader>fh", show_help, "Show help tags")
        keymap("n", "<leader>fW", fuzzy_find_tuc_in_ws, "Find text under cursor (in workspace)")
        keymap("n", "<leader>fw", fuzzy_find_tuc_in_cur_buf, "Find text under cursor (in buffer)")
        keymap("n", "<leader>fb", show_buffers, "List open files [<Leader>,]")
        keymap("n", "<leader>,", show_buffers, "List open files")
        keymap('n', '<leader>fd', find_diagnostics, 'List diagnostics')
        keymap('n', '<leader>fr', resume, 'Resume search')
        keymap('n', '<leader>f.', find_in_cur_buf, 'Find in buffer')
        keymap('n', '<leader>.', find_in_cur_buf, 'Find in buffer')
        keymap('n', '<leader>f/', find_in_open_bufs, 'Find in open files')
        keymap('n', '<leader>/', find_in_open_bufs, 'Find in open files')

        -- Shortcut for searching your Neovim configuration files
        keymap('n', '<leader>fn', function()
            builtin.find_files { cwd = vim.fn.stdpath 'config' }
        end, 'Search neovim files')
    end,
}
