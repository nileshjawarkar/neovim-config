return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        local extensions = (function()
            return {
                noname = { sections = { lualine_a = { function() return "UNNAMED" end }, lualine_b = {}, lualine_z = { "location" }, }, filetypes = { '' } },
                lazy_ext = { sections = { lualine_a = { function() return "LAZY PLUGINS" end }, lualine_b = {}, lualine_z = { "location" }, }, filetypes = { 'lazy' } },
                mason_ext = { sections = { lualine_a = { function() return "MASON" end }, lualine_b = {}, lualine_z = { "location" }, }, filetypes = { 'mason' } },
                -- nvimtree_ext = { sections = { lualine_a = { function() return "FILES" end }, lualine_b = { "branch" }, lualine_z = { "location" }, }, filetypes = { 'NvimTree' } },
                telescope_ext = { sections = { lualine_a = { function() return "TELESCOPE" end }, lualine_b = {}, lualine_z = { "location" }, }, filetypes = { 'TelescopePrompt' } },
                qf_ext = { sections = { lualine_a = { function() return "QUICK LIST" end }, lualine_b = {}, lualine_z = { "location" }, }, filetypes = { 'qf' } },
                snacks_explorer = { sections = { lualine_a = { function() return "FILES" end }, lualine_b = { "branch" }, lualine_z = { "location" }, }, filetypes = { 'snacks_picker_list' } },
                -- snacks_picker = { sections = { lualine_a = { function() return "SNACKS PICKER" end }, lualine_b = {}, lualine_z = { "location" }, }, filetypes = { 'snacks_picker_input' } },
                snacks_input = { sections = { lualine_a = { function() return "INPUT" end }, lualine_b = {}, lualine_z = { "location" }, }, filetypes = { 'snacks_input' } },
                git = { sections = { lualine_a = { function() return "GIT" end }, lualine_b = { "branch" }, lualine_z = { "location" }, }, filetypes = { 'NeogitStatus' } },
            }
        end)()

        require("lualine").setup({
            options = {
                icons_enabled = false,
                theme = "auto",
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                ignore_focus = {},
                always_divide_middle = true,
                globalstatus = true,
                refresh = {
                    statusline = 100,
                    tabline = 200,
                    winbar = 300,
                },
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "filename" },
                lualine_c = { "diff", "diagnostics" },
                lualine_x = { "encoding", "filetype" },
                lualine_y = {},
                lualine_z = { "location" },
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { "filename" },
                lualine_x = { "location" },
                lualine_y = {},
                lualine_z = {},
            },
            tabline = {},
            winbar = {},
            inactive_winbar = {},
            extensions = extensions,
        })
    end,
}
