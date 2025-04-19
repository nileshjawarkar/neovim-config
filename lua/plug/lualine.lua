return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        local extensions = (function()
            local prepare_name = function(name)
                return function()
                    return name
                end
            end
            return {
                noname = { sections = { lualine_a = { prepare_name("UNNAMED") }, lualine_b = {}, lualine_z = { "location" }, }, filetypes = { '' } },
                lazy_ext = { sections = { lualine_a = { prepare_name("LAZY PLUGINS") }, lualine_b = {}, lualine_z = { "location" }, }, filetypes = { 'lazy' } },
                mason_ext = { sections = { lualine_a = { prepare_name("MASON") }, lualine_b = {}, lualine_z = { "location" }, }, filetypes = { 'mason' } },
                -- nvimtree_ext = { sections = { lualine_a = { prepare_name("FILES") }, lualine_b = { "branch" }, lualine_z = { "location" }, }, filetypes = { 'NvimTree' } },
                telescope_ext = { sections = { lualine_a = { prepare_name("TELESCOPE") }, lualine_b = {}, lualine_z = { "location" }, }, filetypes = { 'TelescopePrompt' } },
                qf_ext = { sections = { lualine_a = { prepare_name("QUICK LIST") }, lualine_b = {}, lualine_z = { "location" }, }, filetypes = { 'qf' } },
                snacks_explorer = { sections = { lualine_a = { prepare_name("FILES") }, lualine_b = { "branch" }, lualine_z = { "location" }, }, filetypes = { 'snacks_picker_list' } },
                -- snacks_picker = { sections = { lualine_a = { prepare_name("SNACKS PICKER") }, lualine_b = {}, lualine_z = { "location" }, }, filetypes = { 'snacks_picker_input' } },
                snacks_input = { sections = { lualine_a = { prepare_name("INPUT") }, lualine_b = {}, lualine_z = { "location" }, }, filetypes = { 'snacks_input' } },
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
