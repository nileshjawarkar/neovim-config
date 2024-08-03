return {
    "nvim-tree/nvim-tree.lua",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("config.filemanager").setup()
    end,
}
--[[
return {
    'stevearc/oil.nvim',
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
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
            view_options = {
                show_hidden = false,
                is_hidden_file = function(name, _)
                    if name == ".nvim" or name == ".gitignore" then
                        return false
                    end
                    return vim.startswith(name, ".")
                end,
            },
        })
        vim.keymap.set("n", "<leader>-", oil.open_float, { desc = "Locate current file" })
        vim.keymap.set("n", "<leader>_", function()
            oil.open_float(require("core.util.sys").find_root())
        end, { desc = "Open root folder" })
        vim.keymap.set("n", "<leader>tl", oil.open_float, { desc = "Locate current file" })
        vim.keymap.set("n", "<leader>tr", function()
            oil.open_float(require("core.util.sys").find_root())
        end, { desc = "Open root folder" })
        vim.keymap.set("n", "<leader>th", oil.toggle_hidden, { desc = "Show hidden files (toggle)" })
    end,
}
]]

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
