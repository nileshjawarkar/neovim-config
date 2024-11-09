return {
    setup = function(lsp_config)
        require("mason").setup({
            ui = {
                border = 'rounded',
                width = 0.8,
                height = 0.8,
            },
        })
        require('mason-tool-installer').setup({
            ensure_installed = {
                "lua_ls", "clangd", "pyright", "bashls",
                "jsonls", "yamlls", "dockerls", "jdtls",
                "quick_lint_js", "cssls", "ts_ls",
                "clang-format", "cpptools", "prettier",
                "emmet-language-server", "java-debug-adapter",
                "java-test", "xmlformatter"
            },
        })
        vim.api.nvim_command('MasonToolsInstall')
        require("mason-lspconfig").setup_handlers(lsp_config)
    end,
}
