local function split_horizontally(height)
    -- Create a new horizontal split and open it
    vim.api.nvim_command('new')
    local win_id = vim.api.nvim_get_current_win()
    -- Set height
    if height ~= nil then
        vim.api.nvim_win_set_height(win_id, height)
    end
    return win_id
end

-- Function to find the window with the maximum size
local function find_max_size_window()
    local max_area = 0
    local max_win_id = nil
    for _, win_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local width = vim.api.nvim_win_get_width(win_id)
        local height = vim.api.nvim_win_get_height(win_id)
        local area = width * height

        if area > max_area then
            max_area = area
            max_win_id = win_id
        end
    end
    return max_win_id
end

local function split_max_size_window(min_size_percent)
    local max_win_id = find_max_size_window()
    if not max_win_id then
        print("No windows found.")
        return nil
    end
    -- move cursor to max_win_id
    vim.api.nvim_set_current_win(max_win_id)
    -- manage 70, 30 split
    local total_lines = vim.api.nvim_win_get_height(0)
    local smaller_window_lines = math.floor(total_lines * min_size_percent)
    return split_horizontally(smaller_window_lines)
end

local function is_buf_terminal(buf)
    local bufname = vim.api.nvim_buf_get_name(buf)
    if bufname:find("term://") then
        return true
    end
    return false
end

local function find_terminal_buf()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if is_buf_terminal(buf) then
            return buf
        end
    end
    return nil
end

-- Function to split the maximum size window and open terminal
local function split_and_set_terminal(term_buf)
    local win_id = split_max_size_window(0.30)
    if win_id == nil then return end
    vim.api.nvim_set_current_win(win_id)
    -- we already has term buffer -> set it to current window
    -- or else create new one
    if term_buf ~= nil then
        vim.api.nvim_set_current_buf(term_buf)
    else
        vim.cmd('terminal')
        term_buf = vim.api.nvim_win_get_buf(0)
    end
    -- start insert mode
    vim.cmd('startinsert')
end


local term_buf = nil
local function open_or_hide_terminal()
    -- Step 1 - Find buffer of type terminal
    -- Do it only if term_buf is nil and not of type term_buf
    if term_buf == nil or not is_buf_terminal(term_buf) then
        term_buf = find_terminal_buf()
    end
    -- Step 2 - if no terminal buffer found..
    -- split max size window and create new
    if term_buf == nil then
        split_and_set_terminal()
        return 0
    end
    -- Step 3 - If terminal buffer exists,
    -- check if it is hidden, if hidden split max sise window
    -- and set it to new window.

    -- Here win_id == -1, indicate hidden window
    local win_id = vim.fn.bufwinid(term_buf)
    if win_id == -1 then
        split_and_set_terminal(term_buf)
        return 0
    end
    -- Step 4 - If we are here, it means it  is active window
    -- and hide it for toggle
    vim.api.nvim_win_hide(win_id)
    return 1
end

local function toggleTerm()
    -- exit terminal mode
    if vim.bo.buftype == 'terminal' then
        vim.api.nvim_feedkeys([[<C-\><C-n>]], 'n', true)
    end
    -- open or hide terminal
    if 0 == open_or_hide_terminal() then
        require("config.dap").close()
        require("config.nvimtree").close()
    end
end

vim.keymap.set({ "n" }, "<Leader>T", toggleTerm, { noremap = true, silent = true, desc = "Terminal (C-t)" })
vim.keymap.set({ "n", "t" }, "<C-t>", toggleTerm, { noremap = true, silent = true })
vim.keymap.set({ "n", "t" }, "<M-t>", toggleTerm, { noremap = true, silent = true })

return {
    split_horizontally = split_horizontally,
    find_max_size_window = find_max_size_window,
    split_max_size_window = split_max_size_window,
    is_buf_terminal = is_buf_terminal,
    find_terminal_buf = find_terminal_buf,
}
