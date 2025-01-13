local m = (function()
    local setup_nvimtree = function()
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
        vim.opt.termguicolors = true

        require("nvim-tree").setup({
            renderer = {
                add_trailing = false,
                group_empty = false,
                highlight_git = false,
                highlight_opened_files = 'none',
                root_folder_modifier = ':t',
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
                adaptive_size = true,
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
        setup = setup_nvimtree,
        close = function()
            vim.cmd("NvimTreeClose")
        end
    }
end)()

return m
