vim.g.mapleader = " "
local keymap = vim.keymap

-- Window management
------------------------------
keymap.set("n", "<leader>wv", "<C-w>v", { noremap = true, silent = true, desc = "Split vertically" })
keymap.set("n", "<leader>ws", "<C-w>s", { noremap = true, silent = true, desc = "Split horizontally" })
keymap.set("n", "<leader>wq", ":close<CR>", { noremap = true, silent = true, desc = "Close" })
keymap.set("n", "<leader>wh", "<C-w>h", { noremap = true, silent = true, desc = "Move right" })
keymap.set("n", "<leader>wl", "<C-w>l", { noremap = true, silent = true, desc = "Move left" })
keymap.set("n", "<leader>wj", "<C-w>j", { noremap = true, silent = true, desc = "Move down" })
keymap.set("n", "<leader>wk", "<C-w>k", { noremap = true, silent = true, desc = "Move up" })
keymap.set("n", "<leader>w=", "<cmd>vertical resize +10<cr>", { noremap = true, silent = true, desc = "Increase width" })
keymap.set("n", "<leader>w-", "<cmd>vertical resize -10<cr>", { noremap = true, silent = true, desc = "Decrease width" })

-- Buffer management
------------------------------
keymap.set("n", "<leader>bq", ":bdelete<CR>", { noremap = true, silent = true, desc = "Close buffer" })
keymap.set("n", "<leader>bn", ":bnext<CR>", { noremap = true, silent = true, desc = "Next buffer" })
keymap.set("n", "<leader>bp", ":bprevious<CR>", { noremap = true, silent = true, desc = "Prev buffer" })

-- Utillity key binding
------------------------------
keymap.set("n", "<M-c>", '<cmd>let @+ = expand("%:p")<CR>', { desc = "Copy file path"})
keymap.set("t", "<M-\\>", vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, true, true), { desc = "Exit terminal mode"})

-- Quickfix keymaps
------------------------------
-- Quick list management : For telescope C+q add search results to quick list.
keymap.set("n", "<leader>qo", ":copen<CR>", { noremap = true, silent = true, desc = "Open list" })
keymap.set("n", "<leader>qf", ":cfirst<CR>", { noremap = true, silent = true, desc = "Jump to first item" })
keymap.set("n", "<leader>qn", ":cnext<CR>", { noremap = true, silent = true, desc = "Jump to next item" })
keymap.set("n", "<leader>qp", ":cprev<CR>", { noremap = true, silent = true, desc = "Jump to prev item" })
keymap.set("n", "<leader>ql", ":clast<CR>", { noremap = true, silent = true, desc = "Jump to last item" })
keymap.set("n", "<leader>qq", ":cclose<CR>", { noremap = true, silent = true, desc = "Close" })

keymap.set("v", "<", "<gv", { desc = "Indent left in visual mode" })
keymap.set("v", ">", ">gv", { desc = "Indent right in visual mode" })
