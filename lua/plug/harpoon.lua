return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local harpoon = require("harpoon")
        harpoon:setup()

        vim.keymap.set("n", "<C-m>", function() harpoon:list():add() end)
        vim.keymap.set("n", "<leader>fa", function() harpoon:list():add() end, {desc = "Add to mark file list",})
        vim.keymap.set("n", "<leader>fl", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, {desc = "List marked files"})

        vim.keymap.set("n", "<C-7>", function() harpoon:list():select(1) end)
        vim.keymap.set("n", "<C-8>", function() harpoon:list():select(2) end)
        vim.keymap.set("n", "<C-9>", function() harpoon:list():select(0) end)
        vim.keymap.set("n", "<C-0>", function() harpoon:list():select(4) end)

        vim.keymap.set("n", "<M-S-P>", function() harpoon:list():prev() end)
        vim.keymap.set("n", "<M-S-N>", function() harpoon:list():next() end)
    end,
}
