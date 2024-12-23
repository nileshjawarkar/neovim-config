return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 550
        local wk = require("which-key")
        wk.setup({
            preset = "modern",
            show_help = false,
            show_keys = false,
            win = {
                title = false,
                border = "single",
            },
            plugins = {
                marks = false,
                registers = false,
                presets = {
                    operators = false,
                    motions = false,
                    text_objects = false,
                    windows = false,
                    nav = false,
                    z = false,
                    g = false,
                },
            },
            triggers = {
                { "<leader>", mode = { "n", "v" } },
            },
        })
        wk.add({
            { "<leader>f", group = "Find using telescope", },
            { "<leader>e", group = "Tree view", },
            { "<leader>l", group = "Code Lsp", },
            { "<leader>b", group = "Buffer", },
            { "<leader>B", group = "Breakpoint", },
            { "<leader>lw", group = "Workspace", },
            { "<leader>w", group = "Window", },
            { "<leader>q", group = "Quickfix list", },
            { "<leader>d", group = "Diagnostics", },
            { "<leader>D", group = "Debug", },
            { "<leader>t", group = "Run test", },
        })
    end
}
