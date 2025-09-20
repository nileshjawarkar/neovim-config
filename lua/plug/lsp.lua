return {
    -- lsp
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "mason-org/mason-lspconfig.nvim",
            -- completion
            -- "hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
            "saghen/blink.cmp",
        },
        config = function()
            require("config.lsp").setup()
        end,
    },
    -- dap
    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            -- ui plugins to make debugging simplier
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
            "theHamsta/nvim-dap-virtual-text",
            -- "nvim-telescope/telescope-dap.nvim",
        },
        config = function()
            require("config.dap").setup()
        end,
    }
}
