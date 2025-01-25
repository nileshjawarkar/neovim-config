return {
    "mfussenegger/nvim-lint",
    config = function()
        local registry = require("mason-registry")
        local linters_by_ft = {
        }
        if registry.is_installed("cpplint") then
            linters_by_ft.cpp = {"cpplint"}
        end

        if registry.is_installed("quick-lint-js") then
            linters_by_ft.js = {"quick-lint-js"}
        end

        require('lint').linters_by_ft = linters_by_ft
        vim.keymap.set("n", "<Leader>L",  function()
            require("lint").try_lint();
            require("lint").try_lint("codespell")
        end, {desc = "Code lint"})
    end
}
