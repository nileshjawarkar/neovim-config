return {
    'stevearc/oil.nvim',
    opts = {},
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local oil = require("oil")
        oil.setup({
            float = {
                padding = 5,
                border = "rounded",
                win_options = {
                    winblend = 0,
                },
                preview_split = "auto",
            },
        })
        vim.keymap.set("n", "-", oil.open_float, {})
        vim.keymap.set("n", "<leader>tt", function()
           oil.toggle_float(require("core.util.sys").find_root())
        end, { desc = "Open root folder (toggle)" })
        vim.keymap.set("n", "<leader>tl", function()
           oil.toggle_float()
        end, { desc = "Locate current file (toggle)" })
        vim.keymap.set("n", "<leader>th", oil.toggle_hidden, { desc = "Show hidden files (toggle)" })
    end,
}
--[[
return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
    config = function()
        require("neo-tree").setup({
            close_if_last_window = false,
            popup_border_style = "rounded",
            enable_git_status = false,
        })

        vim.keymap.set("n", "<leader>tc", "<cmd>Neotree close<CR>", { desc = "Close view" })
        vim.keymap.set("n", "<leader>tt", "<cmd>Neotree toggle<CR>", { desc = "Toggle view" })
        vim.keymap.set("n", "<leader>tl", "<cmd>Neotree reveal<CR>", { desc = "Locate current file" })
    end,
}
]]
