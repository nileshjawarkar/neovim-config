return {
    {
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {
            library = { { path = '${3rd}/luv/library', words = { 'vim%.uv' } }, },
        },
    },
    {
        'LunarVim/bigfile.nvim',
        event = 'BufReadPre',
        opts = {
            -- File size in MB
            filesize = 2,
            -- features to disable
            features = {
                "lsp",
                "treesitter",
                "indent_blankline",
                "illuminate",
                "syntax",
                "matchparen",
            },
        },
        config = function(_, opts)
            require('bigfile').setup(opts)
        end
    }
}
