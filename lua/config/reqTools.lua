return {
    treesitterExt = {
        "lua", "vim", "vimdoc", -- Basic/Tools
        "markdown", "markdown_inline", -- Notes
        "json", "yaml", "xml", "toml",
        "make", "c", "cpp", "java",     -- languages & buildtool
        "css", "html", "javascript", -- Web
        "c_sharp", -- languages optional
        "python",
    },

    lspExt = {
        "lua_ls", "jsonls", "yamlls",
        "bashls", "dockerls",
        "jdtls", "clangd",
        "cssls", "ts_ls", "emmet_ls", -- Web
        "pyright", -- Python
    },

    toolExt = {
        "shfmt", "shellcheck",
        "java-debug-adapter", "java-test", -- Java
        "codelldb", "cpptools", "cpplint",  -- C, CPP
        "clang-format", "prettier", "xmlformatter",  -- Formatting
        "codespell", -- check spells in code
        "quick_lint_js", 
    },

}
