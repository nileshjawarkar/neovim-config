local M = {}
M.setup = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    vim.opt.termguicolors = true

    local function get_width()
        return (vim.api.nvim_get_option_value("columns", {}) + 1)
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
            },
        },
    })

    local api = require("nvim-tree.api")
    local function preq_close()
        require("core.nvim.handlers").close({ "dap", "git" })
    end
    vim.keymap.set("n", "<leader>el", function()
        preq_close()
        api.tree.open({ find_file = true })
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

require("core.nvim.handlers").register_close_handler("tree", require("nvim-tree.api").tree.close)

return M
