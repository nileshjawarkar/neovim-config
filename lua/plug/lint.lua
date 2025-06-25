return {
    "mfussenegger/nvim-lint",
    config = function()
        local registry = require("mason-registry")
        local linters_by_ft = require('lint').linters_by_ft
        if registry.is_installed("cpplint") then
            linters_by_ft.cpp = { "cpplint" }
        end

        if registry.is_installed("quick-lint-js") then
            linters_by_ft.js = { "quick-lint-js" }
        end

        if registry.is_installed("yamllint") then
            linters_by_ft.yml = { "yamllint" }
            linters_by_ft.yaml = { "yamllint" }
        end

        -- add pmd to the path
        if vim.fn.executable('pmd') == 1 then
            linters_by_ft.java = { "pmd" }
            linters_by_ft.xml = { "pmd" }
        end

        vim.keymap.set("n", "<Leader>L", function()
            require("lint").try_lint();
        end, { desc = "Code lint" })
        vim.keymap.set("n", "<Leader>S", function()
            require("lint").try_lint("cspell");
        end, { desc = "Spell check" })
    end
}
