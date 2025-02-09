return {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    opts = {},
    config = function()
        -- local cmp = require('cmp')
        -- cmp.setup({
        --     sources = cmp.config.sources({
        --         { name = 'render-markdown' },
        --     }),
        -- })
        require('render-markdown').setup({
            heading = {
                sign = false,
                position = 'inline',
                icons = { '󰫎 ' },
                border = true,
            },
        })
    end,
}
