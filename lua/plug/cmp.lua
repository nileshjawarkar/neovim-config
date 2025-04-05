return {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
        {
            'L3MON4D3/LuaSnip',
            build = (function()
                if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
                    return
                end
                return 'make install_jsregexp'
            end)(),
            dependencies = {
                "rafamadriz/friendly-snippets",
            },
        },
        'hrsh7th/cmp-nvim-lsp',
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "saadparwaiz1/cmp_luasnip", -- Snippets source for nvim-cmp
        -- help format
        "onsails/lspkind.nvim",
    },
    config = function()
        require("config.plug.cmp").setup()
    end,
}
