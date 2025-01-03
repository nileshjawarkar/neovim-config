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
            -- Do not open when dap started
            if require("config.dap").is_dap_open() then
                print("Please close the DAP")
                return
            end

            require("config.filemanager").closeTreeView()
            neogit.open({ kind = "replace" })
        end, { desc = "Open git view" })
    end,
}
