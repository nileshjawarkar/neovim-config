local m = {}

m.setup_oil = function()
    local oil = require("oil")
    oil.setup({
        view_options = {
            show_hidden = false,
            is_hidden_file = function(name, _)
                if name == ".git" or name == ".." then
                    return true
                end
                return false
            end,
        },
    })
    vim.keymap.set("n", "<leader>-", oil.open, { desc = "Locate current file" })
    vim.keymap.set("n", "<leader>_", function()
        oil.open(vim.fn.getcwd())
    end, { desc = "Open root folder" })
    vim.keymap.set("n", "<leader>th", oil.toggle_hidden, { desc = "Toggle hidden mode" })
end

m.setup_nvimtree = function()
    local function label(path)
        return vim.fn.fnamemodify(path, ':p:h:t') .. " -"
    end

    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    vim.opt.termguicolors = true

    require("nvim-tree").setup({
        renderer = {
            root_folder_label = label,
        },
        sort = {
            sorter = "case_sensitive",
        },
        filters = {
            dotfiles = false,
        },
        view = {
            width = 40,
            side = "left",
            preserve_window_proportions = true,
        },
        git = {
            enable = false,
        },
    })

    vim.keymap.set("n", "<leader>tl", "<cmd>NvimTreeFindFile<CR>", { desc = "Locate file (Leader-)" })
    vim.keymap.set("n", "<leader>tk", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse" })
    vim.keymap.set("n", "<leader>tt", "<cmd>NvimTreeToggle<CR>", { desc = "Show/Toggle" })
    vim.keymap.set("n", "<leader>tr", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh" })
end

m.closeTreeView = function()
    vim.cmd("NvimTreeClose")
end

return m
