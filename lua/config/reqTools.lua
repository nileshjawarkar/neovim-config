return {
    treesitterExt = {
        "lua", "vim", "vimdoc",        -- Basic/Tools
        "markdown", "markdown_inline", -- Notes
        "json", "yaml", "xml", "toml",
        "make", "c", "cpp", "java",    -- languages & buildtool
        "css", "html", "javascript",   -- Web
        "c_sharp",                     -- languages optional
        "python", "elixir"
    },

    lspExt = {
        "bash-language-server",
        "dockerfile-language-server",
        "html-lsp", "json-lsp", "css-lsp",    -- From same package
        "emmet-language-server",
        "lua-language-server",
        "typescript-language-server",
        "yaml-language-server",
        "jdtls", "clangd", "pyright"
    },

    toolExt = {
        "shfmt", "shellcheck",
        "java-debug-adapter", "java-test",          -- Java
        "codelldb", "cpptools", "cpplint",          -- C, CPP
        "clang-format", "prettier", "xmlformatter", -- Formatting
        "quick-lint-js", "yamllint",
        "cspell", "htmlhint"
    },
}
