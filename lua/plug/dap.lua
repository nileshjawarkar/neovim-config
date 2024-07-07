return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "neovim/nvim-lspconfig",
        -- ui plugins to make debugging simplier
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio"
    },
    config = function()
        -- gain access to the dap plugin and its functions
        local dap = require("dap")
        -- gain access to the dap ui plugin and its functions
        local dapui = require("dapui")

        -- Setup the dap ui with default configuration
        dapui.setup()

        -- setup an event listener for when the debugger is launched
        dap.listeners.before.launch.dapui_config = function()
            -- when the debugger is launched open up the debug ui
            dapui.open()
        end

        -- DAP keymaps : Need review of the following key defs:
        -------------------------------------------
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserDapConfig", {}),
            callback = function(ev)
                vim.keymap.set("n", "<leader>bb", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
                vim.keymap.set("n", "<leader>bc", function()
                    dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
                end, { desc = "Set breakpoint (condition)" })
                vim.keymap.set("n", "<leader>bl", function()
                    dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
                end, { desc = "Set breakpoint/logpoint message" })
                vim.keymap.set("n", '<leader>br', dap.clear_breakpoints, { desc = "Clear all breakpoints" })
                vim.keymap.set("n", '<leader>ba', '<cmd>Telescope dap list_breakpoints<cr>',
                    { desc = "List all breakpoints" })
                vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Continue" })
                vim.keymap.set("n", "<leader>dj", dap.step_over, { desc = "Step over" })
                vim.keymap.set("n", "<leader>dk", dap.step_into, { desc = "Step into" })
                vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "Step out" })
                vim.keymap.set("n", '<leader>dd', function()
                    require('dap').disconnect(); require('dapui').close();
                end, { desc = "Disconnect debug" })
                vim.keymap.set("n", '<leader>dt', function()
                    require('dap').terminate(); require('dapui').close();
                end, { desc = "Terminate debug" })
                vim.keymap.set("n", "<leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>")
                vim.keymap.set("n", "<leader>dl", "<cmd>lua require'dap'.run_last()<cr>")
                vim.keymap.set("n", '<leader>di', function() require "dap.ui.widgets".hover() end)
                vim.keymap.set("n", '<leader>d?',
                    function()
                        local widgets = require "dap.ui.widgets"; widgets.centered_float(widgets.scopes)
                    end)
                vim.keymap.set("n", '<leader>df', '<cmd>Telescope dap frames<cr>')
                vim.keymap.set("n", '<leader>dh', '<cmd>Telescope dap commands<cr>')
                vim.keymap.set("n", '<leader>de',
                    function() require('telescope.builtin').diagnostics({ default_text = ":E:" }) end)
            end,
        })
    end,
}
