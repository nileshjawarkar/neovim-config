return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "folke/lazydev.nvim",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",

        -- completion
        "hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        { "hrsh7th/nvim-cmp", event = { "InsertEnter", "CmdlineEnter" }, },

        -- snippet
        "saadparwaiz1/cmp_luasnip", -- Snippets source for nvim-cmp
        "L3MON4D3/LuaSnip",         -- Snippets plugin
        "rafamadriz/friendly-snippets",

        -- help format
        "onsails/lspkind.nvim",
    },
    config = function()
        require("config.lsp").setup()
    end,
}
