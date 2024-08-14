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
    vim.keymap.set("n", "<leader>tl", oil.open, { desc = "Locate current file [<Leader>-]" })

    vim.keymap.set("n", "<leader>_", function()
        oil.open(vim.fn.getcwd())
    end, { desc = "Open root folder" })
    vim.keymap.set("n", "<leader>tr", function()
        oil.open(vim.fn.getcwd())
    end, { desc = "Open root folder [<Leader>_]" })

    vim.keymap.set("n", "<leader>th", oil.toggle_hidden, { desc = "Show hidden files (toggle)" })
end

--[[
m.setup = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    vim.opt.termguicolors = true

    local function label(path)
        return vim.fn.fnamemodify(path, ':p:h:t') .. " -"
    end

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

    vim.keymap.set("n", "<leader>-", "<cmd>NvimTreeFindFile<CR>", { desc = "Locate file" })
    vim.keymap.set("n", "<leader>tl", "<cmd>NvimTreeFindFile<CR>", { desc = "Locate file (Leader-)" })
    vim.keymap.set("n", "<leader>tk", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse" })
    vim.keymap.set("n", "<leader>tt", "<cmd>NvimTreeToggle<CR>", { desc = "Show/Toggle" })
    vim.keymap.set("n", "<leader>tr", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh" })
end ]]

--[[
m.setup_neotree = function()
    require("neo-tree").setup({
        close_if_last_window = false,
        popup_border_style = "rounded",
        enable_git_status = false,
    })

    vim.keymap.set("n", "<leader>tc", "<cmd>Neotree close<CR>", { desc = "Close view" })
    vim.keymap.set("n", "<leader>tt", "<cmd>Neotree toggle<CR>", { desc = "Toggle view" })
    vim.keymap.set("n", "<leader>tl", "<cmd>Neotree reveal<CR>", { desc = "Locate current file" })
end ]]

m.closeTreeView = function()
    -- vim.cmd("NvimTreeClose")
end

return m
