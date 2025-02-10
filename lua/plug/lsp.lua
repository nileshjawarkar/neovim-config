return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        -- completion
        "hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
    },
    config = function()
        require("config.lsp").setup()
    end,
}
