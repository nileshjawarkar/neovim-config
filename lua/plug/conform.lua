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
        local formatters = {}
        local formatters_by_ft = {
            lua = { "stylua" },
        }

        if registry.is_installed("clang-format") then
            formatters.fmtjava = {
                command = 'clang-format',
                args = { "--style", "{BasedOnStyle: Google, IndentWidth: 4, TabWidth: 4, UseTab: Never}", "--assume-filename=.java" },
            }
            formatters.fmtcpp = {
                command = 'clang-format',
                args = { "--style", "{BasedOnStyle: Microsoft, IndentWidth: 4, TabWidth: 4, UseTab: Never}", },
            }

            local fmt = { "fmtcpp", }
            formatters_by_ft.c = fmt
            formatters_by_ft.cpp = fmt
            formatters_by_ft.ino = fmt
            formatters_by_ft.java = { "fmtjava" }
        end

        if registry.is_installed("xmlformatter") then
            formatters.fmtxml = {
                command = 'xmlformat',
                args = {
                    '--preserve', 'pre,literal', '--blanks', '--selfclose',
                    '--disable-inlineformatting', '--preserve-attributes',
                    '--indent', '3', '--indent-char', ' ', '$FILENAME'
                },
            }
            formatters_by_ft.xml = { "fmtxml" }
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
            formatters_by_ft.flow = fmt
            formatters_by_ft.graphql = fmt
            formatters_by_ft.jsx = fmt
            formatters_by_ft.less = fmt
            formatters_by_ft.scss = fmt
            formatters_by_ft.vue = fmt
        end


        require("conform").setup({
            formatters_by_ft = formatters_by_ft,
            formatters = formatters,
        })
    end
}
