return {
    treesitter_req = {
        "json", "yaml", "vim", "vimdoc", -- Basic/Tools
        "make", -- Basic.Tools optional
        "lua", "c", "cpp", "java",       -- languages
        -- "c_sharp", -- languages optional
        -- "css", "html", "javascript", -- Web
        "markdown", "markdown_inline" -- Notes
    },

    mason_req = {
        "lua_ls", "jsonls", "yamlls",
        -- "bashls", "dockerls",
        -- "quick_lint_js", "cssls", "ts_ls", "emmet-language-server", -- Web
        -- "pyright", -- Python
        "jdtls", "java-debug-adapter", "java-test", -- Java
        "clangd", "codelldb", "cpptools", "cpplint",  -- C, CPP
        "clang-format", "prettier", "xmlformatter",  -- Formatting
        "codespell", -- check spells in code
    },

}
