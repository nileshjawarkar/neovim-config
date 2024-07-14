return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 550
        local wk = require("which-key")
        wk.setup({
            preset = "classic",
            ignore_missing = true,
            show_help = false,
            show_keys = false,
            win = {
                title = false,
                border = "single",
            },
            plugins = {
                registers = false,
                presets = {
                    operators = false,    -- adds help for operators like d, y, ...
                    motions = false,      -- adds help for motions
                    text_objects = false, -- help for text objects triggered after entering an operator
                    windows = false,      -- default bindings on <c-w>
                    nav = false,          -- misc bindings to work with windows
                },
            },
            modes = {
                i = false, -- Insert mode
                x = false,
            },
        })
        wk.add({
            { "<leader>f", group = "Search/Telescope", },
            { "<leader>t", group = "Files Manager", },
            { "<leader>g", group = "Lsp", },
            { "<leader>W", group = "Workspaces", },
            { "<leader>w", group = "Window", },
            { "<leader>q", group = "Quickfix list", },
            { "<leader>j", group = "Run test", },
            { "<leader>d", group = "Debug/Diagnostic", },
        })
    end

}
