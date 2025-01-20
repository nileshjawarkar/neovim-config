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
            require("core.nvim.handlers").close({"dap", "tree", "qf", "term"})
            neogit.open({ kind = "replace" })
        end, { desc = "Open git view" })

        require("core.nvim.handlers").register_close_handler("git", function()
            if vim.bo.filetype == "NeogitStatus" then
                vim.cmd("bdelete")
            end
        end)
    end,
}
