local m = (function()
    -- o : NoOilNoTree, 1 : OilNoTree, 2 : TreeNoOil
    local mode = 0
    local setup_oil = function()
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
        vim.keymap.set("n", "<leader>-", function()
            if mode == 2 then
                vim.cmd("NvimTreeClose")
            end
            mode = 1
            oil.open()
        end, { desc = "Locate current file" })
        vim.keymap.set("n", "<leader>_", function()
            if mode == 2 then
                vim.cmd("NvimTreeClose")
            end
            mode = 1
            oil.open(vim.fn.getcwd())
        end, { desc = "Open root folder" })
        vim.keymap.set("n", "<leader>th", oil.toggle_hidden, { desc = "Toggle hidden mode" })
    end

    local setup_nvimtree = function()
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

        local api = require("nvim-tree.api")
        vim.keymap.set("n", "<leader>tl", function()
            if mode == 1 then
                require("oil").close()
            end
            mode = 2
            vim.cmd("NvimTreeFindFile")
        end, { desc = "Locate file (Leader-)" })
        vim.keymap.set("n", "<leader>tt", function()
            if mode == 1 then
                require("oil").close()
            end
            mode = 2
            api.tree.toggle()
        end, { desc = "Toggle tree" })
        vim.keymap.set("n", "<leader>tk", api.tree.collapse_all, { desc = "Collapse tree" })
        vim.keymap.set("n", "<leader>tr", api.tree.reload, { desc = "Refresh" })
        vim.keymap.set("n", "<leader>th", api.tree.toggle_help, { desc = "Show help" })
        vim.keymap.set("n", "<leader>tR", api.tree.change_root_to_parent, { desc = "Open root" })
        vim.keymap.set("n", "<leader>td", api.tree.change_root_to_node, { desc = "Set as root" })
    end

    local closeTreeView = function()
        if mode == 2 then
            vim.cmd("NvimTreeClose")
        end
        if mode == 1 then
            require("oil").close()
        end
        mode = 0
    end

    return {
        setup_oil = setup_oil,
        setup_nvimtree = setup_nvimtree,
        closeTreeView = closeTreeView,
    }
end)()

return m
