return {
    setup = function(lsp_config)
        require("mason").setup({
            PATH = 'append',
            log_level = vim.log.levels.INFO,
            max_concurrent_installers = 8,
            ui = {
                check_outdated_packages_on_open = true,
                border = 'rounded',
                width = 0.8,
                height = 0.8,
                keymaps = {
                    toggle_package_expand = '<CR>',
                    install_package = 'i',
                    update_package = 'u',
                    check_package_version = 'c',
                    update_all_packages = 'U',
                    check_outdated_packages = 'C',
                    uninstall_package = 'x',
                    cancel_installation = '<C-c>',
                    apply_language_filter = '<C-f>',
                },
            },
        })
        require('mason-tool-installer').setup({
            ensure_installed = {
                "lua_ls", "clangd", "pyright", "bashls",
                "jsonls", "yamlls", "dockerls", "jdtls",
                "quick_lint_js", "cssls", "ts_ls",
                "clang-format", "cpptools", "prettier",
                "emmet-language-server", "java-debug-adapter",
                "java-test", "xmlformatter",
                "codelldb",
            },
        })
        vim.api.nvim_command('MasonToolsInstall')
        require("mason-lspconfig").setup_handlers(lsp_config)
    end,
}
