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

-- Function to split the maximum size window and open terminal
local function split_and_open_terminal(term_buf)
    local max_win_id = find_max_size_window()
    if not max_win_id then
        print("No windows found.")
        return
    end

    -- move cursor to max_win_id
    vim.api.nvim_set_current_win(max_win_id)

    -- manage 70, 30 split
    local total_lines = vim.api.nvim_win_get_height(0)
    local smaller_window_lines = math.floor(total_lines * 0.30)
    vim.cmd('split')
    vim.cmd('resize ' .. smaller_window_lines)

    -- move to smaller/lower window
    vim.cmd('wincmd j')
    -- we already has term buffer -> set it to current window
    -- or else create new one
    if term_buf ~= nil then
        vim.api.nvim_set_current_buf(term_buf)
    else
        vim.cmd('terminal')
    end

    -- start insert mode
    vim.cmd('startinsert')
end
local function is_buf_terminal(buf)
    local bufname = vim.api.nvim_buf_get_name(buf)
    if bufname:find("term://") then
        return true
    end
    return false
end

local term_buf = nil
local function open_or_hide_terminal()
    -- Iterate over all buffers
    if term_buf == nil or is_buf_terminal(term_buf) then
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if is_buf_terminal(buf) then
                term_buf = buf
                break
            end
        end
    end

    -- If terminal buffer exists, use it
    if term_buf then
        local win_id = vim.fn.bufwinid(term_buf)
        if win_id == -1 then
            -- hidden windows
            split_and_open_terminal(term_buf)
        else
            vim.api.nvim_win_hide(win_id)
        end
    else
        split_and_open_terminal()
    end
end

local function toggleTerm()
    if vim.bo.buftype == 'terminal' then
        vim.api.nvim_feedkeys([[<C-\><C-n>]], 'n', true)
    end
    open_or_hide_terminal()
end

vim.keymap.set({ "n" }, "<Leader>T", toggleTerm, { noremap = true, silent = true, desc = "Terminal (C-t)" })
vim.keymap.set({ "n", "t" }, "<C-t>", toggleTerm, { noremap = true, silent = true })
