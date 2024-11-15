return {
    'nvim-treesitter/nvim-treesitter',
    config = function()
        require 'nvim-treesitter.configs'.setup({
            ensure_installed = {
                "c", "lua", "cpp", "java", "c_sharp",
                "css", "html", "javascript",
                "json", "make", "yaml", "vim", "vimdoc",
                "markdown", "markdown_inline"
            },
            sync_install = false,
            auto_install = false,
            ignore_install = {},
            indent = {
                enable = true
            },
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            modules = {
            },
        })
    end
}
