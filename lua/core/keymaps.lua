vim.g.mapleader = " "

local keymap = vim.keymap

-- Window split management
keymap.set("n", "<leader>wv", "<C-w>v", { noremap = true, silent = true, desc = "vertically" })
keymap.set("n", "<leader>ws", "<C-w>s", { noremap = true, silent = true, desc = "horizontally" })
keymap.set("n", "<leader>w=", "<C-w>=", { noremap = true, silent = true, desc = "Make it equal" })
keymap.set("n", "<leader>wx", ":close<CR>", { noremap = true, silent = true, desc = "Close" })

-- Quick list management
-- Info : For telescope C+q add search results to quick list.
-- Quickfix keymaps
keymap.set("n", "<leader>qo", ":copen<CR>", { noremap = true, silent = true, desc = "Open list" })
keymap.set("n", "<leader>qf", ":cfirst<CR>", { noremap = true, silent = true, desc = "Jump to first item" })
keymap.set("n", "<leader>qn", ":cnext<CR>", { noremap = true, silent = true, desc = "Jump to next item" })
keymap.set("n", "<leader>qp", ":cprev<CR>", { noremap = true, silent = true, desc = "Jump to prev item" })
keymap.set("n", "<leader>ql", ":clast<CR>", { noremap = true, silent = true, desc = "Jump to last item" })
keymap.set("n", "<leader>qc", ":cclose<CR>", { noremap = true, silent = true, desc = "Close" })
