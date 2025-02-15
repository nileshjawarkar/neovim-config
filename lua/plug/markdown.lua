return {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = {
        'nvim-treesitter/nvim-treesitter',
        'nvim-tree/nvim-web-devicons'
    },
    opts = {},
    config = function()
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
