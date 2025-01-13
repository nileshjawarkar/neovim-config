return {
    "NeogitOrg/neogit",
    event = "VeryLazy",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "sindrets/diffview.nvim",
        "nvim-telescope/telescope.nvim",
    },
    config = function()
        local neogit = require('neogit')
        neogit.setup({
            signs = {
                -- { CLOSED, OPENED }
                hunk = { "+", "" },
                item = { "+", "" },
                section = { "+", "" },
            },
        })
        vim.keymap.set("n", "<leader>G", function()
            local dap = require("config.dap")
            if dap ~= nil then
                dap.close()
            end
            require("config.filetree").close()
            neogit.open({ kind = "replace" })
        end, { desc = "Open git view" })
    end,
}
