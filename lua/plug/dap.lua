return {
    "rcarriga/nvim-dap-ui",
    dependencies = {
        -- ui plugins to make debugging simplier
        "mfussenegger/nvim-dap",
        "nvim-neotest/nvim-nio",
        "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
        require("nvim-dap-virtual-text").setup()
        -- gain access to the dap plugin and its functions
        local dap = require("dap")

        -- Set up icons.
        local icons = {
            Stopped = { '#', 'DiagnosticWarn', 'DapStoppedLine' },
            Breakpoint = '*',
            BreakpointCondition = '*',
            BreakpointRejected = { 'x', 'DiagnosticError' },
            LogPoint = '>',
        }
        for name, sign in pairs(icons) do
            sign = type(sign) == 'table' and sign or { sign }
            vim.fn.sign_define('Dap' .. name, {
                text = sign[1] --[[@as string]] .. ' ',
                texthl = sign[2] or 'DiagnosticInfo',
                linehl = sign[3],
                numhl = sign[3],
            })
        end

        -- gain access to the dap ui plugin and its functions
        local dapui = require("dapui")

        -- Setup the dap ui with default configuration
        local settings = {
            controls = {
                element = "repl",
                enabled = false,
            },
            layouts = { {
                elements = { {
                    id = "scopes",
                    size = 0.30
                }, {
                    id = "breakpoints",
                    size = 0.20
                }, {
                    id = "watches",
                    size = 0.20
                }, {
                    id = "stacks",
                    size = 0.30
                } },
                position = "left",
                size = 35,
            }, {
                elements = { {
                    id = "repl",
                    size = 0.5,
                }, {
                    id = "console",
                    size = 0.5,
                } },
                position = "bottom",
                size = 10
            } },
        }
        dapui.setup(settings)

        local function open_dapui()
            dapui.open()
            require("neo-tree").close_all()
        end
        -- setup an event listener for when the debugger is launched
        dap.listeners.before.attach.dapui_config = function()
            open_dapui()
        end
        dap.listeners.before.launch.dapui_config = function()
            open_dapui()
        end

        --[[
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        ]]

        -- DAP keymaps : Need review of the following key defs:
        -------------------------------------------
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserDapConfig", {}),
            callback = function(_)
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
                vim.keymap.set("n", "<F8>", dap.continue, { desc = "Continue" })
                vim.keymap.set("n", "<F6>", dap.step_over, { desc = "Step over" })
                vim.keymap.set("n", "<F5>", dap.step_into, { desc = "Step into" })
                vim.keymap.set("n", "<F4>", dap.step_out, { desc = "Step out" })
                vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Continue (F8)" })
                vim.keymap.set("n", "<leader>dj", dap.step_over, { desc = "Step over (F6)" })
                vim.keymap.set("n", "<leader>dk", dap.step_into, { desc = "Step into (F5)" })
                vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "Step out (F4)" })
                vim.keymap.set("n", "<leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>")
                vim.keymap.set("n", "<leader>dl", "<cmd>lua require'dap'.run_last()<cr>")
                vim.keymap.set("n", '<leader>df', '<cmd>Telescope dap frames<cr>')
                vim.keymap.set("n", '<leader>dh', '<cmd>Telescope dap commands<cr>')
                vim.keymap.set("n", '<leader>d?', function()
                    local widgets = require "dap.ui.widgets"; widgets.centered_float(widgets.scopes)
                end, { desc = "Open float" })
                vim.keymap.set("n", '<leader>dd', function()
                    require('dap').disconnect();
                    require('dapui').close();
                end, { desc = "Disconnect debug" })
                vim.keymap.set("n", '<leader>dt', function()
                    require('dap').terminate();
                    require('dapui').close();
                end, { desc = "Terminate debug" })
                vim.keymap.set("n", "<leader>da", open_dapui, { desc = "Open DAP ui" })
            end,
        })
    end,
}
