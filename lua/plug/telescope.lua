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
        -- Shorten displayed paths: keep last 3 components and prepend ".../" when longer
        local function path_formater(_, path)
            if not path or path == "" then
                return path
            end
            local parts = {}
            for part in path:gmatch("[^/]+") do
                table.insert(parts, part)
            end
            local n = #parts
            if n <= 5 then
                return path
            end
            local last3 = table.concat({ parts[n - 2], parts[n - 1], parts[n] }, "/")
            return ".../" .. last3
        end

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
                path_display = path_formater,
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

        -- This function will build the handlers function will call
        -- preq-check-exec function before calling telescope specific function.
        local function prepare_handler(fun, args)
            return function()
                local handler = require("config.winhandlers")
                if not handler.isCodeBuffer() then
                    handler.closeNonCodeWindows()
                end
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

        local find_files_with_world = prepare_handler(function()
            local word = vim.fn.expand('<cword>')
            builtin.find_files { default_text = word }
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

        keymap("n", "<leader>ff", find_files, "Find files [<Leader><Leader>]")
        keymap("n", "<leader>fF", find_files_with_world, "Find files with text under-cursor")
        keymap("n", "<leader><leader>", find_files, "Fuzzy find files")
        keymap("n", "<leader>fR", show_recentfile, "Find recent open files")
        keymap("n", "<leader>fg", live_grep, "Find in files")
        keymap("n", "<leader>fh", show_help, "Show help tags")
        keymap("n", "<leader>fW", fuzzy_find_tuc_in_ws, "Find text under cursor (in workspace)")
        keymap("n", "<leader>fw", fuzzy_find_tuc_in_cur_buf, "Find text under-cursor (in buffer)")
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
