local m = {}

m.setup = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    vim.opt.termguicolors = true

    require("nvim-tree").setup({
        auto_reload_on_write = true,
        sort = {
            sorter = "case_sensitive",
        },
        filters = {
            dotfiles = true,
        },
        view = {
            width = 40,
            side = "left",
            preserve_window_proportions = true,
        },
    })

    vim.keymap.set("n", "<leader>-", "<cmd>NvimTreeFindFile<CR>", { desc = "Locate current file" })
    vim.keymap.set("n", "<leader>tl", "<cmd>NvimTreeFindFile<CR>", { desc = "Locate current file" })
    vim.keymap.set("n", "<leader>tt", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle tree view" })
    vim.keymap.set("n", "<leader>tr", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh tree view" })
end

m.closeTreeView = function()
    vim.cmd("NvimTreeClose")
end

return m
