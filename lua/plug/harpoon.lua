return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = {
        "nvim-lua/plenary.nvim",
        -- "nvim-telescope/telescope.nvim",
    },
    config = function()
        local harpoon = require("harpoon")
        harpoon:setup({})

        local function show_files()
            local items = harpoon:list().items or {}
            if #items == 0 then
                vim.notify("Harpoon list is empty", vim.log.levels.INFO)
                return
            end
            local entries = {}
            for idx, item in ipairs(items) do
                local path = item.value or item
                local label = vim.fn.fnamemodify(path, ':~:.')
                table.insert(entries, { idx = idx, path = path, label = label })
            end

            local opts = {
                prompt = "Harpoon files:",
                format_item = function(entry) return entry.label end,
            }

            vim.ui.select(entries, opts, function(choice)
                if not choice then return end
                local ok, list = pcall(function() return harpoon:list() end)
                if ok and list and list.select then
                    pcall(function() list:select(choice.idx) end)
                else
                    -- Fallback: open file directly
                    pcall(vim.cmd, 'edit ' .. vim.fn.fnameescape(choice.path))
                end
            end)
        end

        vim.keymap.set("n", "<leader>bl", function() show_files() end,
            { desc = "Show selected files" })


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
