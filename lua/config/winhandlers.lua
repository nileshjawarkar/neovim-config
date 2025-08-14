local M = {}


-- Cache for non-code file types (using hash table for O(1) lookup)
local non_code_filetypes = {
    qf = true,
    help = true,
    man = true,
    fugitive = true,
    lazy = true,
    mason = true,
    snacks_picker_list = true,
    snacks_picker_input = true,
    snacks_input = true,
    snacks_terminal = true,
    gitcommit = true,
    NeogitConsole = true,
    NeogitPopup = true,
    NeogitStatus = true,
    NvimTree = true,
    ["neo-tree"] = true,
    Trouble = true,
    toggleterm = true,
    term = true,
    TelescopePrompt = true,
    TelescopeResults = true,
    TelescopePreview = true,
    ["dap-repl"] = true,
    dapui_watches = true,
    dapui_stacks = true,
    dapui_breakpoints = true,
    dapui_scopes = true,
    dapui_console = true,
    Outline = true,
    dashboard = true,
    prompt = true,
    nofile = true
}

local code_filetypes = {
    java = true,
    c = true,
    cpp = true,
    py = true
}

-- Check if a buffer is a code file (using modern APIs)
local function isCodeBuffer(buf_id)
    -- If buf_id is nil or not provided, use current window's buffer
    if not buf_id then
        buf_id = vim.api.nvim_win_get_buf(vim.api.nvim_get_current_win())
    end

    -- Use modern vim.bo API instead of deprecated nvim_buf_get_option
    local buf_type = vim.bo[buf_id].buftype
    local file_type = vim.bo[buf_id].filetype
    local buf_name = vim.api.nvim_buf_get_name(buf_id)

    if buf_name ~= "" and code_filetypes[file_type] then
        return true
    end

    -- Skip special buffer types (only allow empty or acwrite)
    if buf_type ~= "" and buf_type ~= "acwrite" then
        return false
    end

    -- Use hash table for fast filetype lookup
    if non_code_filetypes[file_type] then
        return false
    end

    -- Skip special buffer names (optimized pattern matching)
    -- Note: Empty buffer names (unnamed buffers) are now considered code buffers
    if buf_name ~= "" then
        local first_part = buf_name:sub(1, 7)
        if first_part == "term://" or first_part == "fugitiv" or
            first_part == "git://" or buf_name:match("^dap%-") then
            return false
        end
    end

    return true
end

-- Close all non-code windows (using modern APIs)
M.closeNonCodeWindows = function(preserve_current)
    local all_wins = vim.api.nvim_tabpage_list_wins(0)
    -- Only execute if more than one window is open
    if #all_wins <= 1 then
        return 0
    end

    local current_win = vim.api.nvim_get_current_win()
    local closed_count = 0
    local code_windows = {}

    -- Single pass: identify code windows and close non-code windows
    for _, win_id in ipairs(all_wins) do
        local buf_id = vim.api.nvim_win_get_buf(win_id)
        -- Check if this should be preserved (code buffer OR current window if preserve_current is true)
        local should_preserve = isCodeBuffer(buf_id) or (preserve_current and win_id == current_win)

        if should_preserve then
            code_windows[#code_windows + 1] = win_id
        else
            -- Close non-code window immediately using modern APIs
            local file_type = vim.bo[buf_id].filetype
            local buf_name = vim.api.nvim_buf_get_name(buf_id)

            if file_type == "qf" then
                vim.cmd('cclose')
            elseif file_type == "term" or buf_name:match("^term://") then
                pcall(vim.api.nvim_win_close, win_id, false)
            elseif file_type == "NeogitStatus" then
                vim.api.nvim_set_current_win(win_id)
                vim.cmd("bdelete")
            else
                pcall(vim.api.nvim_win_close, win_id, false)
            end
            closed_count = closed_count + 1
        end
    end

    -- Ensure at least one window remains and handle current window
    if #code_windows == 0 then
        -- If no code windows, keep current window
        code_windows[1] = current_win
    else
        -- Switch to first code window if current was closed
        local current_exists = false
        for _, win_id in ipairs(code_windows) do
            if win_id == current_win then
                current_exists = true
                break
            end
        end
        if not current_exists then
            vim.api.nvim_set_current_win(code_windows[1])
        end
    end

    return closed_count
end

-- Close all non-code windows except current window (preserves current window regardless of type)
M.closeNonCodeWindowsExceptCurrent = function()
    return M.closeNonCodeWindows(true)
end

M.isEmptyBuffer = function(buf_id)
    if not buf_id then
        buf_id = vim.api.nvim_win_get_buf(vim.api.nvim_get_current_win())
    end
    local buf_type = vim.bo[buf_id].buftype
    local file_type = vim.bo[buf_id].filetype
    local buf_name = vim.api.nvim_buf_get_name(buf_id)
    if buf_name == "" and buf_type == "" and file_type == "" then
        return true
    end
    return false
end

-- Export isCodeBuffer function for external use
M.isCodeBuffer = isCodeBuffer

return M
