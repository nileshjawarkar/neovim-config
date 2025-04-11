local win = require("core.nvim.win")
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
        vim.api.nvim_set_current_buf(term_buf)
    else
        vim.cmd('terminal')
        term_buf = vim.api.nvim_win_get_buf(0)
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
            vim.api.nvim_win_hide(win_id)
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
    -- exit terminal mode
    if vim.bo.buftype == 'terminal' then
        vim.api.nvim_feedkeys([[<C-\><C-n>]], 'n', true)
    end
    setTermBuf();
    -- If window active hide it
    if hideTerm() then
        return 1
    end
    -- if term_buf nil or hidden, create new window
    openTerm()
    -- Close dap windows if open
    require("core.nvim.handlers").close({ "dap" })
end

require("core.nvim.handlers").register_close_handler("term", function()
    if vim.bo.filetype == "term" then
        hideTerm()
        return true
    end
    return false
end)

vim.keymap.set({ "n" }, "<Leader>T", toggleTerm, { noremap = true, silent = true, desc = "Terminal (C-t)" })
vim.keymap.set({ "n", "t" }, "<C-t>", toggleTerm, { noremap = true, silent = true })
vim.keymap.set({ "n", "t" }, "<M-t>", toggleTerm, { noremap = true, silent = true })

return {
    toggleTerm = toggleTerm,
    hideTerm = hideTerm,
    openTerm = openTerm,
}
