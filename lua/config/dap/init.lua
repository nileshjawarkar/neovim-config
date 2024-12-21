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

local function dap_open()
    require("dap").repl.close()
    require("dapui").open()
    require("config.filemanager").closeTreeView()
end

local function dap_close()
    require("dap").repl.close()
    require("dapui").close()
    if vim.api.nvim_win_get_buf(0) == nil then
        vim.cmd("buffer")
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

    vim.keymap.set("n", "<leader>Dc", dap.continue, { desc = "Continue [<F8>]" })
    vim.keymap.set("n", "<leader>Dj", dap.step_over, { desc = "Step over [<F6>]" })
    vim.keymap.set("n", "<leader>Dk", dap.step_into, { desc = "Step into [<F5>]" })
    vim.keymap.set("n", "<leader>Do", dap.step_out, { desc = "Step out [<F4>]" })
    vim.keymap.set("n", "<leader>DC", dap.run_to_cursor, { desc = "Run to cursor [<F7>]" })
    vim.keymap.set("n", '<leader>Dd', function()
        dap_close()
        dap.disconnect();
    end, { desc = "Disconnect debug" })
    vim.keymap.set("n", '<leader>Dt', function()
        dap_close()
        dap.terminate();
    end, { desc = "Terminate debug" })

    -- utility ui
    vim.keymap.set("n", "<leader>Dl", "<cmd>lua require'dap'.run_last()<cr>", { desc = "Run last", })
    vim.keymap.set("n", '<leader>Df', '<cmd>Telescope dap frames<cr>', { desc = "Show frames", })
    vim.keymap.set("n", '<leader>Dh', '<cmd>Telescope dap commands<cr>', { desc = "Show commands", })
    vim.keymap.set("n", '<leader>D?', function()
        local widgets = require "dap.ui.widgets"; widgets.centered_float(widgets.scopes)
    end, { desc = "Open scopes" })
    vim.keymap.set("n", "<leader>Da", dap_open, { desc = "Open DapUI" })
    vim.keymap.set("n", "<leader>Dr", function()
        dap.repl.toggle()
    end, { desc = "Toggle repl", })

    -- breakpoint management
    vim.keymap.set("n", "<leader>B", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
    vim.keymap.set("n", "<leader>Bc", function()
        dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
    end, { desc = "Set breakpoint (condition)" })
    vim.keymap.set("n", "<leader>Bs", function()
        dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
    end, { desc = "Set breakpoint/logpoint message" })
    vim.keymap.set("n", '<leader>Br', dap.clear_breakpoints, { desc = "Clear all breakpoints" })
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
    dap.listeners.before.attach.dapui_config = dap_open
    dap.listeners.before.launch.dapui_config = dap_open

    --[[
    dap.listeners.after.event_exited.dapui_config = dap_close
    dap.listeners.after.event_terminated.dapui_config = dap_close
    ]]
end

return {
    setup = setup,
    setup_keys = setup_keys,
    setup_dap_config = require("config.lsp.ws_config").dap_setup,
}
