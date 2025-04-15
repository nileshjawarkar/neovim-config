-- Function to create a new horizontal split with a specified height
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

-- Function to split the window with the maximum size
-- and return the new split window ID
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

return  {
    split_horizontally = split_horizontally,
    find_max_size_window = find_max_size_window,
    split_max_size_window = split_max_size_window,
}
