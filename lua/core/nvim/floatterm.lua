local term_state = {
    win_id = nil,
    bufnr = nil,
}

local function cal_size_and_loc()
    local win_id = vim.api.nvim_get_current_win()
    local width = vim.api.nvim_win_get_width(win_id)
    local height = vim.api.nvim_win_get_height(win_id)

    -- Calculate the floating window's dimensions (half the size)
    local float_width = width - math.floor(width / 12)
    local float_height = math.floor(height / 2)

    -- Define position for the floating window (you can adjust the row/column if needed)
    local row = math.floor((height - float_height)) - math.floor(height / 12)
    local col = math.floor((width - float_width) / 2)

    return {
        width = float_width,
        height = float_height,
        row = row,
        col = col,
    }
end

-- Function to toggle the floating window
local function toggle_floating_term()
    if term_state.win_id and vim.api.nvim_win_is_valid(term_state.win_id) and term_state.bufnr ~= nil then
        -- If the window is already open, hide it
        vim.api.nvim_win_hide(term_state.win_id)
    else
        if not term_state.bufnr or not vim.api.nvim_buf_is_valid(term_state.bufnr) then
            term_state.bufnr = vim.api.nvim_create_buf(false, true)
        end

        -- Get the dimensions of the current (main) window
        local dim = cal_size_and_loc()
        -- Open the floating window
        term_state.win_id = vim.api.nvim_open_win(term_state.bufnr, true, {
            relative = 'editor', -- Relative to the editor
            row = dim.row,       -- Vertical position
            col = dim.col,       -- Horizontal position
            width = dim.width,   -- Width
            height = dim.height, -- Height
            style = "minimal",   -- Minimal style (no status line, fold column, etc.)
            border = "rounded",  -- Border style
        })

        if vim.bo[term_state.bufnr].buftype ~= "terminal" then
            vim.cmd.terminal()
        end
    end
end

vim.api.nvim_create_user_command("ToggleFloatTerm", function()
    toggle_floating_term()
end, {})

-- local function exeToggleTerm()
--     if vim.bo.buftype == 'terminal' then
--         vim.api.nvim_feedkeys([[<C-\><C-n>]], 'n', true)
--     end
--     toggle_floating_term()
-- end
-- vim.keymap.set({"n", "t"}, "<C-t>", exeToggleTerm, {noremap = true, silent = true})
