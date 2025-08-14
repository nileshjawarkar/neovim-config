local function setup_dap_icons()
    local icons = {
        Stopped = { '>', 'DiagnosticWarn', 'DapStoppedLine' },
        Breakpoint = '*',
        BreakpointCondition = '+',
        BreakpointRejected = { '!', 'DiagnosticError' },
        LogPoint = '#',
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
end

local isDapOpen = false;
local function dap_open()
    require("config.winhandlers").closeNonCodeWindows()
    require("dapui").open()
    isDapOpen = true
end

local function dap_close()
    require("dap").repl.close()
    require("dapui").close()
    if vim.api.nvim_win_get_buf(0) == nil then
        vim.cmd("buffer")
    end
    isDapOpen = false
end

local function setup_keys()
    local dap = require("dap")
    local function continue()
        if not require("config.winhandlers").isCodeBuffer() then
            return
        end
        dap.continue()
    end

    -- debug session navigation
    vim.keymap.set("n", "<F8>", continue, { desc = "Continue" })
    vim.keymap.set("n", "<F6>", dap.step_over, { desc = "Step over" })
    vim.keymap.set("n", "<F5>", dap.step_into, { desc = "Step into" })
    vim.keymap.set("n", "<F4>", dap.step_out, { desc = "Step out" })
    vim.keymap.set("n", "<F7>", dap.run_to_cursor, { desc = "Run to cursor" })

    vim.keymap.set("n", "<leader>dc", continue, { desc = "Continue [<F8>]" })
    vim.keymap.set("n", "<leader>dj", dap.step_over, { desc = "Step over [<F6>]" })
    vim.keymap.set("n", "<leader>dk", dap.step_into, { desc = "Step into [<F5>]" })
    vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "Step out [<F4>]" })
    vim.keymap.set("n", "<leader>dC", dap.run_to_cursor, { desc = "Run to cursor [<F7>]" })
    vim.keymap.set("n", '<leader>dd', function()
        dap_close()
        dap.disconnect();
    end, { desc = "Disconnect debug" })
    vim.keymap.set("n", '<leader>dt', function()
        dap_close()
        dap.terminate();
    end, { desc = "Terminate debug" })

    -- utility ui
    vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Run last", })
    vim.keymap.set("n", '<leader>d?', function()
        local widgets = require "dap.ui.widgets"; widgets.centered_float(widgets.scopes)
    end, { desc = "Open scopes" })
    vim.keymap.set("n", "<leader>du", dap_open, { desc = "Open DapUI" })
    vim.keymap.set("n", "<leader>dr", function()
        dap.repl.toggle()
    end, { desc = "Toggle repl", })

    -- breakpoint management
    vim.keymap.set("n", "<leader>Bb", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
    vim.keymap.set("n", "<leader>Bc", function()
        dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
    end, { desc = "Set breakpoint (condition)" })
    vim.keymap.set("n", "<leader>Bs", function()
        dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
    end, { desc = "Set breakpoint/logpoint message" })
    vim.keymap.set("n", '<leader>Br', dap.clear_breakpoints, { desc = "Clear all breakpoints" })

    vim.keymap.set("n", '<leader>df', '<cmd>Telescope dap frames<cr>', { desc = "Show frames", })
    vim.keymap.set("n", '<leader>dh', '<cmd>Telescope dap commands<cr>', { desc = "Show commands", })
    vim.keymap.set("n", '<leader>Bl', '<cmd>Telescope dap list_breakpoints<cr>',
        { desc = "List all breakpoints" })
end

local function setup()
    require('telescope').load_extension('dap')
    require("nvim-dap-virtual-text").setup({})
    setup_dap_icons()
    -- gain access to the dap plugin and its functions
    local dap = require("dap")
    local dapui = require("dapui")
    local debug_settings = {
        controls = {
            element = "repl",
            enabled = false,
        },
        layouts = { {
            elements = {
                { id = "watches", size = 0.25 },
                { id = "scopes",  size = 0.35 },
                { id = "stacks",  size = 0.40 },
            },
            position = "left",
            size = 35,
        }, {
            elements = {
                { id = "console", size = 1.0, }
            },
            position = "bottom",
            size = 10
        } },
    }

    dapui.setup(debug_settings)

    -- setup an event listener for when the debugger is launched
    dap.listeners.before.attach.dapui_config = dap_open
    dap.listeners.before.launch.dapui_config = dap_open
    -- dap.listeners.before.event_exited.dapui_config = dap_close
    -- dap.listeners.before.event_terminated.dapui_config = dap_close
end

return {
    setup = setup,
    setup_keys = setup_keys,
    close = function()
        if isDapOpen then
            dap_close()
            return true
        end
        return false
    end,
}
