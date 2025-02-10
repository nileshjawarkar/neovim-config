return {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function()
        vim.cmd([[colorscheme tokyonight-storm]])
        -- vim.cmd([[colorscheme tokyonight-night]])
        -- vim.cmd([[colorscheme tokyonight-moon]])
        vim.cmd([[hi Comment gui=none]])
    end,
}
