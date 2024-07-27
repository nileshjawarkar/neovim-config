vim.g.mapleader = " "
local keymap = vim.keymap
-- Window management
------------------------------
keymap.set("n", "<leader>wv", "<C-w>v", { noremap = true, silent = true, desc = "Split vertically" })
keymap.set("n", "<leader>ws", "<C-w>s", { noremap = true, silent = true, desc = "Split horizontally" })
keymap.set("n", "<leader>wh", "<C-w>h", { noremap = true, silent = true, desc = "Move right" })
keymap.set("n", "<leader>wl", "<C-w>l", { noremap = true, silent = true, desc = "Move left" })
keymap.set("n", "<leader>wj", "<C-w>j", { noremap = true, silent = true, desc = "Move down" })
keymap.set("n", "<leader>wk", "<C-w>k", { noremap = true, silent = true, desc = "Move up" })
keymap.set("n", "<leader>w=", "<cmd>vertical resize +10<cr>",
    { noremap = true, silent = true, desc = "Increase width" })
keymap.set("n", "<leader>w-", "<cmd>vertical resize -10<cr>",
    { noremap = true, silent = true, desc = "Decrease width" })

-- Shortcuts
keymap.set("n", "<C-h>", "<C-w>h", { noremap = true, silent = true, desc = "Move right" })
keymap.set("n", "<C-l>", "<C-w>l", { noremap = true, silent = true, desc = "Move left" })
keymap.set("n", "<C-j>", "<C-w>j", { noremap = true, silent = true, desc = "Move down" })
keymap.set("n", "<C-k>", "<C-w>k", { noremap = true, silent = true, desc = "Move up" })

keymap.set("v", "<", "<gv", { desc = "Indent left in visual mode" })
keymap.set("v", ">", ">gv", { desc = "Indent right in visual mode" })

-- Utillity key binding
------------------------------
keymap.set({ "i", "n" }, "<C-s>", "<ESC><CMD>:wa<CR>", { noremap = true, silent = true, desc = "Save session" })


keymap.set("n", "<leader>fp", function()
    local pn = vim.fn.expand('%:p')
    vim.cmd("let @+ = \'" ..  pn .. "\'")
    print( "Copied - " ..  pn )
end, { noremap = true, silent = true, desc = "Copy file path" })
keymap.set("n", "<leader>fP", function()
    local n = vim.fn.expand('%:p:t')
    vim.cmd("let @+ = \'" ..  n .. "\'")
    print( "Copied - " ..  n )
end, { noremap = true, silent = true, desc = "Copy file name" })

-- Quickfix keymaps
------------------------------
-- Quick list management : For telescope C+q add search results to quick list.
keymap.set("n", "<leader>qo", ":copen<CR>", { noremap = true, silent = true, desc = "Open list" })
keymap.set("n", "<leader>qf", ":cfirst<CR>", { noremap = true, silent = true, desc = "Jump to first item" })
keymap.set("n", "<leader>qn", ":cnext<CR>", { noremap = true, silent = true, desc = "Jump to next item" })
keymap.set("n", "<leader>qp", ":cprev<CR>", { noremap = true, silent = true, desc = "Jump to prev item" })
keymap.set("n", "<leader>ql", ":clast<CR>", { noremap = true, silent = true, desc = "Jump to last item" })

keymap.set("n", "<leader><Tab>", ":bn<CR>", { noremap = true, silent = true, desc = "Move to next buffer" })
keymap.set("n", "<leader>qq", function()
        vim.cmd("bdelete")
        vim.cmd("cclose")
end, { noremap = true, silent = true, desc = "Close list/buffer" })

-- terminal management
--------------------------
keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", {noremap = true, silent = true})
keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", {noremap = true, silent = true})
keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", {noremap = true, silent = true})
keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", {noremap = true, silent = true})
keymap.set("n", "<C-t>", ":below terminal<CR>", {noremap = true, silent = true})

