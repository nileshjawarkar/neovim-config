return {
    "NeogitOrg/neogit",
    keys = {
        {
            '<leader>G',
            function()
                require("config.winhandlers").closeNonCodeWindows()
                require('neogit').open({ kind = "replace" })
            end,
            mode = '',
            desc = 'Open git view',
        },
    },
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
        --[[
        vim.keymap.set("n", "<leader>G", function()
            require("config.winhandlers").closeNonCodeWindows()
            neogit.open({ kind = "replace" })
        end, { desc = "Open git view" })
        ]]
    end,
}
