return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
    },
    config = function()
        local harpoon = require("harpoon")
        harpoon:setup({})

        -- basic telescope configuration
        local conf = require("telescope.config").values
        local function toggle_telescope(harpoon_files)
            local file_paths = {}
            for _, item in ipairs(harpoon_files.items) do
                table.insert(file_paths, item.value)
            end

            require("telescope.pickers").new({}, {
                prompt_title = "Selected files",
                finder = require("telescope.finders").new_table({
                    results = file_paths,
                }),
                -- previewer = conf.file_previewer({}),
                previewer = false,
                sorter = conf.generic_sorter({}),
            }):find()
        end

        vim.keymap.set("n", "<leader>fe", function() toggle_telescope(harpoon:list()) end,
            { desc = "Show selected list" })

        vim.keymap.set("n", "<leader>bA", function() harpoon:list():add() end, { desc = "Add to selected list" })

        local replace_or_add = (function()
            local function isBufSuported()
                local buftype = vim.bo.filetype
                if buftype == "NvimTree" or buftype == "mason"
                    or buftype == "lazy" or buftype == "NeogitStatus"
                    or buftype == "dapui_watches" or buftype == "dapui_scopes"
                    or buftype == "dapui_stacks" or buftype == "dapui_console"
                    or buftype == "qf" then
                    vim.notify("Can not add \"" .. buftype .. "\" to the selected-file list", vim.log.levels.INFO)
                    return false
                end
                return true
            end
            return function(index)
                return function()
                    if isBufSuported() == false then
                        return
                    end
                    if harpoon:list():length() < index then
                        harpoon:list():add()
                    else
                        harpoon:list():replace_at(index)
                    end
                end
            end
        end)()

        vim.keymap.set("n", "<leader>ba1", replace_or_add(1), { desc = "@Index 1" })
        vim.keymap.set("n", "<leader>ba2", replace_or_add(2), { desc = "@Index 2" })
        vim.keymap.set("n", "<leader>ba3", replace_or_add(3), { desc = "@Index 3" })
        vim.keymap.set("n", "<leader>ba4", replace_or_add(4), { desc = "@Index 4" })

        vim.keymap.set("n", "<leader>b1", function() harpoon:list():select(1) end, { desc = "Show selected file 1" })
        vim.keymap.set("n", "<leader>b2", function() harpoon:list():select(2) end, { desc = "Show selected file 2" })
        vim.keymap.set("n", "<leader>b3", function() harpoon:list():select(3) end, { desc = "Show selected file 3" })
        vim.keymap.set("n", "<leader>b4", function() harpoon:list():select(4) end, { desc = "Show selected file 4" })
        vim.keymap.set("n", "<leader>bR", function() harpoon:list():clear() end, { desc = "Clear selected list" })
    end
}
