local m = (function()
    local treeHandler = (function()
        -- o : NoOilNoTree, 1 : OilNoTree, 2 : TreeNoOil
        local mode = 0
        return {
            closeNTree = function()
                if mode == 2 then
                    vim.cmd("NvimTreeClose")
                end
                mode = 1
            end,
            closeOil = function()
                if mode == 1 then
                    require("oil").close()
                end
                mode = 2
            end,
            closeBoth = function()
                if mode == 2 then
                    vim.cmd("NvimTreeClose")
                end
                if mode == 1 then
                    require("oil").close()
                end
                mode = 0
            end
        }
    end)()

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
            treeHandler.closeNTree()
            oil.open()
        end, { desc = "Locate current file" })
        vim.keymap.set("n", "<leader>_", function()
            treeHandler.closeNTree()
            oil.open(vim.fn.getcwd())
        end, { desc = "Open root folder" })
        vim.keymap.set("n", "<leader>eH", oil.toggle_hidden, { desc = "Toggle hidden mode" })
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
            notify = {
                threshold = vim.log.levels.WARN,
                absolute_path = false,
            },
        })

        local api = require("nvim-tree.api")
        local function preq_close()
            local dap = require("config.dap")
            if dap ~= nil then
                if dap.is_dap_open() then
                    dap.close()
                end
            end
            treeHandler.closeOil()
        end

        vim.keymap.set("n", "<leader>el", function()
            preq_close()
            vim.cmd("NvimTreeFindFile")
        end, { desc = "Locate file" })
        vim.keymap.set("n", "<leader>ee", function()
            preq_close()
            api.tree.toggle()
        end, { desc = "Toggle tree" })
        vim.keymap.set("n", "<leader>ek", api.tree.collapse_all, { desc = "Collapse tree" })
        vim.keymap.set("n", "<leader>er", api.tree.reload, { desc = "Refresh" })
        vim.keymap.set("n", "<leader>eh", api.tree.toggle_help, { desc = "Show help" })
        vim.keymap.set("n", "<leader>eR", api.tree.change_root_to_parent, { desc = "Open root" })
        vim.keymap.set("n", "<leader>ed", api.tree.change_root_to_node, { desc = "Set as root" })
    end

    return {
        setup_oil = setup_oil,
        setup_nvimtree = setup_nvimtree,
        closeTreeView = treeHandler.closeBoth,
    }
end)()

return m
