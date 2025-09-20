return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        -- Helper function to create simple extensions
        local function create_extension(name, filetypes, with_branch)
            local sections = {
                lualine_a = { function() return name end },
                lualine_z = { "location" },
            }
            if with_branch then
                sections.lualine_b = { "branch" }
            end
            return { sections = sections, filetypes = filetypes }
        end

        local extensions = {
            create_extension("UNNAMED", { '' }),
            create_extension("PLUGINS", { 'lazy' }),
            create_extension("MASON", { 'mason' }),
            create_extension("TELESCOPE", { 'TelescopePrompt' }),
            create_extension("QUICK LIST", { 'qf' }),
            create_extension("PICKER", { 'snacks_picker_input' }),
            create_extension("FILES", { 'snacks_picker_list' }, true),
            create_extension("INPUT", { 'snacks_input' }),
            create_extension("TERMINAL", { 'snacks_terminal' }),
            create_extension("GIT", { 'NeogitStatus', 'NeogitConsole', 'NeogitPopup', 'gitcommit', 'NeogitCommitView' }, true),
            create_extension("DAP", { "dapui_watches", "dapui_scopes", "dapui_stacks", "dapui_console" }),
        }

        require("lualine").setup({
            options = {
                icons_enabled = false,
                theme = "auto",
                component_separators = "",
                section_separators = "",
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
                lualine_z = { "location" },
            },
            inactive_sections = {
                lualine_c = { "filename" },
                lualine_x = { "location" },
            },
            extensions = extensions,
        })
    end,
}
