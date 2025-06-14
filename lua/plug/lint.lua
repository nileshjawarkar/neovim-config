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

        local isCS = registry.is_installed("codespell")
        local isTupo = registry.is_installed("tupos")

        vim.keymap.set("n", "<Leader>L", function()
            require("lint").try_lint();
            if isCS == true then require("lint").try_lint("codespell") end
            if isTupo == true then require("lint").try_lint("typos") end
        end, { desc = "Code lint" })
    end
}
