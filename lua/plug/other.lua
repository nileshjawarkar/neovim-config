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
        opts = { filesize = 2, },
        config = function(_, opts)
            require('bigfile').setup(opts)
        end
    }
}
