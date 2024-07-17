local function setup_dap_icons()
    local icons = {
        Stopped = { '>', 'DiagnosticWarn', 'DapStoppedLine' },
        Breakpoint = '*',
        BreakpointCondition = '*',
        BreakpointRejected = { 'x', 'DiagnosticError' },
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

local function setup_keys()
    local dap = require("dap")

    -- debug session navigation
    vim.keymap.set("n", "<F8>", dap.continue, { desc = "Continue" })
    vim.keymap.set("n", "<F6>", dap.step_over, { desc = "Step over" })
    vim.keymap.set("n", "<F5>", dap.step_into, { desc = "Step into" })
    vim.keymap.set("n", "<F4>", dap.step_out, { desc = "Step out" })
    vim.keymap.set("n", "<F7>", dap.run_to_cursor, { desc = "Run to cursor" })

    vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Continue (F8)" })
    vim.keymap.set("n", "<leader>dj", dap.step_over, { desc = "Step over (F6)" })
    vim.keymap.set("n", "<leader>dk", dap.step_into, { desc = "Step into (F5)" })
    vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "Step out (F4)" })
    vim.keymap.set("n", "<leader>dC", dap.run_to_cursor, { desc = "Run to cursor (F7)" })
    vim.keymap.set("n", '<leader>dd', function()
        dap.disconnect();
        require('dapui').close();
    end, { desc = "Disconnect debug" })
    vim.keymap.set("n", '<leader>dt', function()
        dap.terminate();
        require('dapui').close();
    end, { desc = "Terminate debug" })

    -- utility ui
    vim.keymap.set("n", "<leader>dl", "<cmd>lua require'dap'.run_last()<cr>", { desc = "Run last", })
    vim.keymap.set("n", '<leader>df', '<cmd>Telescope dap frames<cr>', { desc = "Show frames", })
    vim.keymap.set("n", '<leader>dh', '<cmd>Telescope dap commands<cr>', { desc = "Show commands", })
    vim.keymap.set("n", '<leader>d?', function()
        local widgets = require "dap.ui.widgets"; widgets.centered_float(widgets.scopes)
    end, { desc = "Open scopes" })
    vim.keymap.set("n", "<leader>da", function()
        require("dapui").open()
    end, { desc = "Open DAP ui" })

    vim.keymap.set("n", "<leader>dr", function()
        require("dapui").close()
        dap.repl.toggle()
    end, { desc = "Open repl", })

    -- breakpoint management
    vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
    vim.keymap.set("n", "<leader>dbb", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
    vim.keymap.set("n", "<leader>dbc", function()
        dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
    end, { desc = "Set breakpoint (condition)" })
    vim.keymap.set("n", "<leader>dbs", function()
        dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
    end, { desc = "Set breakpoint/logpoint message" })
    vim.keymap.set("n", '<leader>dbr', dap.clear_breakpoints, { desc = "Clear all breakpoints" })
    vim.keymap.set("n", '<leader>dbl', '<cmd>Telescope dap list_breakpoints<cr>',
        { desc = "List all breakpoints" })

    -- generic close
    require("core.keymaps").register_with_leader_qq("dap-repl", function()
        dap.repl.close()
    end)
end

local function setup()
    require('telescope').load_extension('dap')
    require("nvim-dap-virtual-text").setup({})
    setup_dap_icons()
    -- gain access to the dap plugin and its functions
    local dap = require("dap")
    local dapui = require("dapui")
    local settings = {
        controls = {
            element = "repl",
            enabled = false,
        },
        layouts = { {
            elements = {
                { id = "watches", size = 0.20 },
                { id = "scopes",  size = 0.40 },
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

    dapui.setup(settings)

    -- setup an event listener for when the debugger is launched
    local function dap_open()
        dap.repl.close()
        require("dapui").open()
        vim.cmd("buffer")
    end
    dap.listeners.before.attach.dapui_config = dap_open
    dap.listeners.before.launch.dapui_config = dap_open

    local function dap_close()
        require("dapui").close()
        dap.repl.open()
        vim.cmd("buffer")
    end
    dap.listeners.after.event_exited.dapui_config = dap_close
    dap.listeners.after.event_terminated.dapui_config = dap_close
end


local function load_dap_config(ws_path)
    local config_path = loadfile(ws_path .. "/.nvim/config.lua")
    if type(config_path) == "function" then
        config_path()
    end
end

return {
    setup = setup,
    setup_keys = setup_keys,
    load_dap_config = load_dap_config,
}
