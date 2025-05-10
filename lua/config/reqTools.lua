return {
    treesitter_req = {
        "lua", "vim", "vimdoc", -- Basic/Tools
        "markdown", "markdown_inline", -- Notes
        "json", "yaml", "xml", "toml",
        "make", "c", "cpp", "java",     -- languages & buildtool
        "css", "html", "javascript", -- Web
        "c_sharp", -- languages optional
        "python",
    },

    mason_req = {
        "lua_ls", "jsonls", "yamlls",
        "bashls", "shfmt", "shellcheck", "dockerls",
        "jdtls", "java-debug-adapter", "java-test", -- Java
        "clangd", "codelldb", "cpptools", "cpplint",  -- C, CPP
        "clang-format", "prettier", "xmlformatter",  -- Formatting
        "codespell", -- check spells in code
        "quick_lint_js", "cssls", "ts_ls", "emmet-language-server", -- Web
        "pyright", -- Python
    },

}
