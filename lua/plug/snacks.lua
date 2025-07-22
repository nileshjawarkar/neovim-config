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
        {
            "<M-t>",
            function()
                Snacks.terminal()
            end,
            desc = "Toggle Terminal",
            mode = { "n", "t" },
        },
        {
            "<leader>T",
            function()
                Snacks.terminal()
            end,
            desc = "Toggle Terminal",
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
    end,
}
