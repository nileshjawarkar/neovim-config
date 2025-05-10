return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
        -- completion
        -- "hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
        'saghen/blink.cmp',
    },
    config = function()
        require("config.lsp").setup()
    end,
}
