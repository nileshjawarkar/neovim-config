local keymap = vim.keymap

keymap.set("n", "<leader>qo", ":copen<CR>", { noremap = true, silent = true, desc = "Open list" })
keymap.set("n", "<leader>qq", ":cclose<CR>", { noremap = true, silent = true, desc = "Close list" })
keymap.set("n", "<leader>qf", ":cfirst<CR>", { noremap = true, silent = true, desc = "Jump to first" })
keymap.set("n", "<leader>qn", ":cnext<CR>", { noremap = true, silent = true, desc = "Jump to next" })
keymap.set("n", "<leader>qp", ":cprev<CR>", { noremap = true, silent = true, desc = "Jump to prev" })
keymap.set("n", "<leader>ql", ":clast<CR>", { noremap = true, silent = true, desc = "Jump to last" })

local function remove_from_qf_list()
    if vim.bo.filetype ~= "qf" then
        return
    end

    local curqfidx = vim.fn.line('.')
    local qfall = vim.fn.getqflist()

    -- Return if there are no items to remove
    if #qfall == 0 then return end

    -- Remove the item from the quickfix list
    table.remove(qfall, curqfidx)
    vim.fn.setqflist(qfall, 'r')

    -- Reopen quickfix window to refresh the list
    -- vim.cmd('copen')

    -- If not at the end of the list, stay at the same index, otherwise, go one up.
    local new_idx = curqfidx < #qfall and curqfidx or math.max(curqfidx - 1, 1)

    -- Set the cursor position directly in the quickfix window
    local winid = vim.fn.win_getid() -- Get the window ID of the quickfix window
    vim.api.nvim_win_set_cursor(winid, { new_idx, 0 })
end


local function clear_qf_list()
    vim.fn.setqflist({}, 'r')
    vim.cmd("cclose")
end

--[[ Need to add checks to avoid duplicate entry
local function add_to_qf_list()
    if vim.bo.filetype == "qf" then
        return
    end

    local qfall = vim.fn.getqflist()
    -- Return if there are no items to remove
    if qfall == nil then
        qfall = {}
    end

    local curfile = { filename = vim.fn.bufname(), lnum = #qfall + 1 }
    -- Add curbuf file to list
    table.insert(qfall, curfile)
    vim.fn.setqflist(qfall, 'r')
end 
keymap.set("n", "<leader>qa", add_to_qf_list, { noremap = true, silent = true, desc = "Add current file" })
]]

keymap.set("n", "<leader>qr", remove_from_qf_list, { noremap = true, silent = true, desc = "Delete line" })
keymap.set("n", "<leader>qR", clear_qf_list, { noremap = true, silent = true, desc = "Delete all lines" })
