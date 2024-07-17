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
                    operators = false,    -- adds help for operators like d, y, ...
                    motions = false,      -- adds help for motions
                    text_objects = false, -- help for text objects triggered after entering an operator
                    windows = false,      -- default bindings on <c-w>
                    nav = false,          -- misc bindings to work with windows
                    z = false,             -- bindings for folds, spelling and others prefixed with z
                    g = false,             -- bindings for prefixed with g
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
            { "<leader>l", group = "Lsp", },
            { "<leader>lw", group = "Workspace", },
            { "<leader>w", group = "Window", },
            { "<leader>q", group = "Quickfix list", },
            { "<leader>j", group = "Run test", },
            { "<leader>d", group = "Debug/Diagnostic", },
            { "<leader>db", group = "Breakpoint", },
        })
    end

}
