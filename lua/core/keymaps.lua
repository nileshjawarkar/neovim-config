vim.g.mapleader = " "

local keymap = vim.keymap

keymap.set("n", "<leader>wv", "<C-w>v")     -- split window vertically
keymap.set("n", "<leader>ws", "<C-w>s")     -- split window horizontally
keymap.set("n", "<leader>w=", "<C-w>=")     -- make split windows equal width & height
keymap.set("n", "<leader>wx", ":close<CR>") -- close current split window
