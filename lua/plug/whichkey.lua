return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 550
        local wk = require("which-key")
        wk.setup({
            plugins = {
                registers = false,
            },
            window = {
                border = "single",        -- none, single, double, shadow
                position = "bottom",      -- bottom, top
                margin = { 1, 0, 0, 0 },  -- extra window margin [top, right, bottom, left]. When between 0 and 1, will be treated as a percentage of the screen size.
                padding = { 1, 1, 1, 1 }, -- extra window padding [top, right, bottom, left]
                winblend = 0,             -- value between 0-100 0 for fully opaque and 100 for fully transparent
                zindex = 1000,            -- positive value to position WhichKey above other floating windows.
            },
            layout = {
                height = { min = 4, max = 25 }, -- min and max height of the columns
                width = { min = 20, max = 50 }, -- min and max width of the columns
                spacing = 2,                    -- spacing between columns
                align = "left",                 -- align columns left, center or right
            },
            triggers_nowait = {
                "`",
                "'",
                '"',
                "z=",
            },
            ignore_missing = true,
            show_help = false, -- show a help message in the command line for using WhichKey
            show_keys = false, -- show the currently pressed key and its label as a message in the command line
        })
        wk.register({
            f = { name = "Telescope", },
            t = { name = "File tree", },
            g = { name = "Lsp", },
            W = { name = "Workspaces", },
            w = { name = "Window", },
            q = { name = "Quickfix list", },
            u = { name = "Utility functions", },
            ["e"] = "which_key_ignore",
        }, {
            prefix = "<leader>"
        })
    end

}
