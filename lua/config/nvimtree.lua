local M = {}
M.setup = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    vim.opt.termguicolors = true

    local function get_width()
        return vim.api.nvim_get_option_value("columns", {})
    end

    require("nvim-tree").setup({
        sort = { sorter = "case_sensitive", },
        filters = { dotfiles = false, },
        git = { enable = false, },
        renderer = {
            add_trailing = false,
            group_empty = false,
            highlight_git = false,
            highlight_opened_files = 'none',
            root_folder_modifier = ':t',
        },
        view = {
            width = get_width,
            side = "left",
            preserve_window_proportions = true,
        },
        notify = {
            threshold = vim.log.levels.WARN,
            absolute_path = false,
        },
        actions = {
            open_file = {
                quit_on_open = true,
                window_picker = {
                    enable = false
                },
            },
        },
    })

    local api = require("nvim-tree.api")
    vim.keymap.set("n", "<leader>el", function()
        require("config.handlers").closeThemForMe("tree")
        api.tree.open({ find_file = true })
    end, { desc = "Locate file" })
    vim.keymap.set("n", "<leader>ee", function()
        require("config.handlers").closeThemForMe("tree")
        api.tree.toggle()
    end, { desc = "Toggle tree" })
    vim.keymap.set("n", "<leader>ek", api.tree.collapse_all, { desc = "Collapse tree" })
    vim.keymap.set("n", "<leader>er", api.tree.reload, { desc = "Refresh" })
    vim.keymap.set("n", "<leader>eh", api.tree.toggle_help, { desc = "Show help" })
    vim.keymap.set("n", "<leader>eR", api.tree.change_root_to_parent, { desc = "Open root" })
    vim.keymap.set("n", "<leader>ed", api.tree.change_root_to_node, { desc = "Set as root" })
end

return M
