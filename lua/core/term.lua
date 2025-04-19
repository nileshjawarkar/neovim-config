local win = require("core.util.win")
-- local/private variables
local term_buf = nil

-- Function to check if a buffer is a terminal buffer
local function is_buf_terminal(buf)
    if not vim.api.nvim_buf_is_valid(buf) then
        return false
    end
    local bufname = vim.api.nvim_buf_get_name(buf)
    if bufname ~= nil then
        return bufname:find("term://") ~= nil
    end
    return false
end

-- Function to find an existing terminal buffer
local function find_terminal_buf()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if is_buf_terminal(buf) then
            return buf
        end
    end
    return nil
end

-- Function to split the maximum size window and open terminal
local function openTerm()
    local win_id = win.split_max_size_window(0.40)
    if win_id == nil then return end
    vim.api.nvim_set_current_win(win_id)
    -- we already has term buffer -> set it to current window
    -- or else create new one
    if term_buf ~= nil then
        -- Get buffer from splied window and delete it after setting
        -- terminal buffer
        local temp_buf_id = vim.api.nvim_win_get_buf(win_id)
        -- Set terminal buffer
        vim.api.nvim_set_current_buf(term_buf)
        -- Delete the temp buffer
        vim.api.nvim_buf_delete(temp_buf_id, { force = true })
    else
        vim.cmd('terminal')
        term_buf = find_terminal_buf()
        vim.bo.filetype = "term"
    end
    -- start insert mode
    vim.cmd('startinsert')
end

local function hideTerm()
    if term_buf ~= nil then
        local win_id = vim.fn.bufwinid(term_buf)
        -- Here win_id == -1, indicate hidden window
        if win_id ~= -1 then
            vim.api.nvim_win_close(win_id, true)
            return true
        end
    end
    return false
end

local function setTermBuf()
    --  Find buffer of type terminal
    -- Do it only if term_buf is nil and not of type term_buf
    if term_buf == nil or not is_buf_terminal(term_buf) then
        term_buf = find_terminal_buf()
    end
end

local function toggleTerm()
    -- If window active hide it
    if hideTerm() then
        return
    end
    -- If we want to close some plugin window, befor staring term..
    -- we need to do it here...befor setTermBuf.
    require("config.handlers").closeThemForMe("term")
    -- if term_buf nil or hidden, create new window
    setTermBuf();
    openTerm()
end


-- vim.keymap.set({ "n" }, "<Leader>T", toggleTerm, { noremap = true, silent = true, desc = "Terminal (C-t)" })
-- vim.keymap.set({ "n", "t" }, "<M-t>", toggleTerm, { noremap = true, silent = true })

return {
    toggleTerm = toggleTerm,
    hideTerm = hideTerm,
    openTerm = openTerm,
}
