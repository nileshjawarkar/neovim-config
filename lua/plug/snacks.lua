return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        bigfile = { enabled = true },
        explorer = { replace_netrw = true },
        input = { enabled = true },
        quickfile = { enabled = true },
        scope = { enabled = true },
        words = { enabled = true },
        -- indent = { enabled = true },
        scroll = { enabled = true },
        statuscolumn = { enabled = true },
        terminal = {
            win = { style = "minimal" },
        },
        dim = { enabled = true },
        picker = {
            sources = {
                explorer = {
                    title = "Files",
                    tree = true,
                    auto_close = true,
                    diagnostics = false,
                    git_status = false,
                    layout = { preview = false, fullscreen = true, hidden = { "input" } },
                    actions = {
                        recursive_toggle = function(picker, item)
                            local Tree = require("snacks.explorer.tree")
                            local node = Tree:node(item.file)
                            -- If not dir, then perform default action
                            -- and return
                            if not node or not node.dir then
                                picker:action("confirm")
                                return
                            end

                            -- If node and its pointing to dir, then
                            -- recursively expand it.
                            -- else, open it
                            local Actions = require("snacks.explorer.actions")
                            local function toggle_recursive(curNode)
                                Tree:open(Tree:dir(curNode.path))
                                Actions.update(picker, { refresh = true })
                                vim.schedule(function()
                                    -- Expand if current node has only one child.
                                    local child = nil
                                    for _, c in pairs(curNode.children) do
                                        -- *Recursive expand should work, if node has only one child.
                                        -- if child is not nil, it means current node
                                        -- has children > 1, so nothing to do... return.
                                        if child ~= nil then
                                            return
                                        end
                                        child = c
                                    end
                                    if child ~= nil and child.dir then
                                        toggle_recursive(child)
                                    end
                                end)
                            end
                            toggle_recursive(node)
                        end,
                    },
                    win = {
                        list = {
                            keys = {
                                ["<Esc>"] = "",
                                ["l"] = "",
                                ["E"] = "recursive_toggle",
                            },
                        },
                    },
                },
                files = {
                    layout = { preview = false },
                    cmd = "rg",
                },
                buffers = {
                    layout = { preview = false },
                },
                grep = {
                    title = "Find in files",
                },
            },
        },
    },
    keys = {
        -- search
        { '<leader>fr', function() Snacks.picker.registers() end,       desc = "Registers" },
        { '<leader>fS', function() Snacks.picker.search_history() end,  desc = "Search History" },
        { "<leader>fj", function() Snacks.picker.jumps() end,           desc = "Jumps" },
        { "<leader>fk", function() Snacks.picker.keymaps() end,         desc = "Keymaps" },
        { "<leader>fL", function() Snacks.picker.loclist() end,         desc = "Location List" },
        { "<leader>fm", function() Snacks.picker.marks() end,           desc = "Marks" },
        { "<leader>fM", function() Snacks.picker.man() end,             desc = "Man Pages" },
        { "<leader>fu", function() Snacks.picker.undo() end,            desc = "Undo History" },
        { "<leader>fC", function() Snacks.picker.colorschemes() end,    desc = "Colorschemes" },
        { "<leader>bd", function() Snacks.bufdelete() end,              desc = "Delete Buffer" },
        { "<leader>bo", function() Snacks.bufdelete.other() end,        desc = "Delete Other Buffers" },
        {
            "<M-t>",
            function()
                -- Close non-code windows before opening terminal
                require("config.winhandlers").closeNonCodeWindowsExceptCurrent()
                Snacks.terminal()
            end,
            desc = "Toggle Terminal",
            mode = { "n", "t" },
        },
        {
            "<leader>T",
            function()
                -- Close non-code windows before opening terminal
                require("config.winhandlers").closeNonCodeWindowsExceptCurrent()
                Snacks.terminal()
            end,
            desc = "Toggle Terminal [M-t]",
            mode = { "n", "t" },
        },
        {
            "<leader>e",
            function()
                Snacks.explorer()
            end,
            desc = "File Explorer",
        },
        {
            "<leader>N",
            desc = "Neovim News",
            function()
                Snacks.win({
                    file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
                    width = 0.7,
                    height = 0.7,
                    wo = {
                        spell = false,
                        wrap = false,
                        signcolumn = "yes",
                        statuscolumn = " ",
                        conceallevel = 3,
                    },
                })
            end,
        },
    },
    init = function()
        vim.api.nvim_create_autocmd("User", {
            pattern = "VeryLazy",
            callback = function()
                -- Setup some globals for debugging (lazy-loaded)
                _G.dd = function(...)
                    Snacks.debug.inspect(...)
                end
                _G.bt = function()
                    Snacks.debug.backtrace()
                end
                vim.print = _G.dd -- Override print to use snacks for `:=` command

                -- Create some toggle mappings
                Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
                Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
                Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
                Snacks.toggle.diagnostics():map("<leader>ud")
                Snacks.toggle.line_number():map("<leader>ul")
                Snacks.toggle
                    .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
                    :map("<leader>uc")
                Snacks.toggle.treesitter():map("<leader>uT")
                Snacks.toggle
                    .option("background", { off = "light", on = "dark", name = "Dark Background" })
                    :map("<leader>ub")
                Snacks.toggle.inlay_hints():map("<leader>uh")
                Snacks.toggle.indent():map("<leader>ug")
                Snacks.toggle.dim():map("<leader>uD")
            end,
        })

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
        local keymap = require("core.util.sys").keymap
        local picker = require("snacks.picker")
        local find_files = prepare_handler(picker.files)
        local live_grep = prepare_handler(picker.grep)
        local show_buffers = prepare_handler(picker.buffers)
        local find_in_cur_buf = prepare_handler(picker.lines)
        local find_in_open_bufs = prepare_handler(picker.grep_buffers)
        local fuzzy_find_tuc_in_ws = prepare_handler(picker.grep_word)
        local show_recent = prepare_handler(picker.recent)
        local show_help = prepare_handler(picker.help)
        local show_diag = prepare_handler(picker.diagnostics)
        local show_buf_diag = prepare_handler(picker.diagnostics_buffer)
        local show_cmd_history = prepare_handler(picker.command_history)
        local show_notif = prepare_handler(picker.notifications)

        keymap("n", "<leader>ff", find_files, "Find files [<Leader><Leader>]")
        keymap("n", "<leader><leader>", find_files, "Fuzzy find files")
        keymap("n", "<leader>fg", live_grep, "Find in files")
        keymap("n", "<leader>fb", show_buffers, "List open files [<Leader>,]")
        keymap("n", "<leader>,", show_buffers, "List open files")
        keymap('n', '<leader>f.', find_in_cur_buf, 'Find in buffer [<Leader>.]')
        keymap('n', '<leader>.', find_in_cur_buf, 'Find in buffer')
        keymap('n', '<leader>f/', find_in_open_bufs, 'Find in open files [<Leader>/]')
        keymap('n', '<leader>/', find_in_open_bufs, 'Find in open files')
        keymap("n", "<leader>fW", fuzzy_find_tuc_in_ws, "Find sel-text in workspace")
        keymap("n", "<leader>fR", show_recent, "Find recent open files")
        keymap("n", "<leader>fh", show_help, "Show help tags")
        keymap('n', '<leader>fd', show_buf_diag, 'Show buffer diagnostics')
        keymap('n', '<leader>fD', show_diag, 'Show diagnostics')
        keymap('n', '<leader>f:', show_cmd_history, 'Show command history')
        keymap('n', '<leader>fn', show_notif, 'Show notifications')

        -- Shortcut for searching your Neovim configuration files
        keymap('n', '<leader>fc', function()
            picker.files({ cwd = vim.fn.stdpath("config") })
        end, 'Search in neovim config')

        -- create a finder for files prefilled with word under cursor
        local find_files_with_word = prepare_handler(function()
            local word = vim.fn.expand('<cword>') or ''
            picker.files({ search = "*" .. word .. "*", live = false, supports_live = false })
        end)
        keymap('n', '<leader>fF', find_files_with_word, 'Find files (word under cursor)')
    end,
}
