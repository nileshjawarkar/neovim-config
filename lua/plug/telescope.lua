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
            extensions = {
                fzf = {},
            }
        })

        -- Enable Telescope extensions if they are installed
        pcall(require('telescope').load_extension, 'live_grep_args')
        pcall(require('telescope').load_extension, 'fzf')

        local function execute_checks_and_preqs()
            local buftype = vim.bo.filetype
            if buftype == "df" then
                vim.cmd("buffer")
                buftype = vim.bo.filetype
            end
            if buftype == "mason" or vim.bo.filetype == "lazy" then
                vim.cmd("bdelete")
            elseif buftype == "dapui_watches" or buftype == "dapui_scopes"
                or buftype == "dapui_stacks" or buftype == "dapui_console" then
                vim.notify("While in DAP, please use telescope from code buffer.", vim.log.levels.INFO)
                return false
            end
            require("core.nvim.handlers").close({"term"})
            return true
        end

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

        local function buf_search_op()
            return {
                previewer = false,
                search_dirs = { vim.fn.expand('%:p'), },
                prompt_title = 'Search in current file',
            }
        end
        local function key_ops(desc)
            return { noremap = true, silent = true, desc = desc }
        end

        local builtin = require("telescope.builtin")

        local find_diagnostics = prepare_handler(builtin.diagnostics)
        local resume = prepare_handler(builtin.resume)
        local find_files = prepare_handler(builtin.find_files)
        local show_buffers = prepare_handler(builtin.buffers)
        local show_recentfile = prepare_handler(builtin.oldfiles)
        local show_help = prepare_handler(builtin.help_tags)
        local fuzzy_find_tuc_in_ws = prepare_handler(builtin.grep_string)
        local fuzzy_find_tuc_in_cur_buf = prepare_handler(builtin.grep_string, buf_search_op)
        local find_in_cur_buf = prepare_handler(builtin.live_grep, buf_search_op)
        local live_grep = prepare_handler(require('telescope').extensions.live_grep_args.live_grep_args)
        local find_in_open_bufs = prepare_handler(function()
            builtin.live_grep {
                grep_open_files = true,
                prompt_title = 'Search in open files',
            }
        end)
        vim.keymap.set("n", "<leader>ff", find_files, key_ops("Fuzzy find files [<Leader><Leader>]"))
        vim.keymap.set("n", "<leader><leader>", find_files, key_ops("Fuzzy find files"))
        vim.keymap.set("n", "<leader>fR", show_recentfile, key_ops("Find recent open files"))
        vim.keymap.set("n", "<leader>fg", live_grep, key_ops("Find text"))
        vim.keymap.set("n", "<leader>fh", show_help, key_ops("Show help tags"))
        vim.keymap.set("n", "<leader>fW", fuzzy_find_tuc_in_ws, key_ops("Find text under cursor (in workspace)"))
        vim.keymap.set("n", "<leader>fw", fuzzy_find_tuc_in_cur_buf, key_ops("Find text under cursor (in buffer)"))
        vim.keymap.set("n", "<leader>fb", show_buffers, key_ops("List open files [<Leader>,]"))
        vim.keymap.set("n", "<leader>,", show_buffers, key_ops("List open files"))
        vim.keymap.set('n', '<leader>fd', find_diagnostics, key_ops('List diagnostics'))
        vim.keymap.set('n', '<leader>fr', resume, key_ops('Resume search'))
        vim.keymap.set('n', '<leader>f.', find_in_cur_buf, key_ops('Find in buffer'))
        vim.keymap.set('n', '<leader>.', find_in_cur_buf, key_ops('Find in buffer'))
        vim.keymap.set('n', '<leader>f/', find_in_open_bufs, key_ops('Find in open files'))
        vim.keymap.set('n', '<leader>/', find_in_open_bufs, key_ops('Find in open files'))

        -- Shortcut for searching your Neovim configuration files
        vim.keymap.set('n', '<leader>fn', function()
            builtin.find_files { cwd = vim.fn.stdpath 'config' }
        end, key_ops('Search neovim files'))
    end,
}
