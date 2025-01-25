return {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
        {
            '<leader>F',
            function()
                require('conform').format { async = true, lsp_format = 'fallback' }
            end,
            mode = '',
            desc = 'Format buffer',
        },
    },
    config = function()
        local registry = require("mason-registry")
        local formatters_by_ft = {
            lua = { "stylua" },
        }
        if registry.is_installed("clang-format") then
            local fmt = {
                "clang-format",
                args = { "--style=Microsoft" },
            }
            formatters_by_ft.c = fmt
            formatters_by_ft.cpp = fmt
            formatters_by_ft.java = {
                "clang-format",
                lsp_format = "fallback",
                args = { '--style="{BasedOnStyle: Google, IndentWidth: 4}"', "--assume-filename=.java" },
            }
        end

        if registry.is_installed("prettier") then
            local fmt = { "prettier", }
            formatters_by_ft.json = fmt
            formatters_by_ft.yaml = fmt
            formatters_by_ft.javascript = fmt
            formatters_by_ft.typescript = fmt
            formatters_by_ft.html = fmt
            formatters_by_ft.css = fmt
            formatters_by_ft.markdown = fmt
        end

        if registry.is_installed("xmlformat") then
            local fmt = {
                "xmlformat",
                args = { '--preserve "pre,literal" --blanks --selfclose --indent 3 --indent-char " " --disable-inlineformatting --disable-correction --eof-newline', '-', },
            }
            formatters_by_ft.xml = fmt
        end

        require("conform").setup({
            formatters_by_ft = formatters_by_ft,
        })
    end
}
