return { {
    'stevearc/oil.nvim',
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    config = function()
        require("config.filemanager").setup_oil()
    end,
}, {
    "nvim-tree/nvim-tree.lua",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("config.filemanager").setup_nvimtree()
    end,
} }
