vim.g.mapleader = " "
local sys = require("core.util.sys")
local keymap = vim.keymap
-- Window management
------------------------------
keymap.set("n", "<leader>wv", "<C-w>v", { noremap = true, silent = true, desc = "Split vertically" })
keymap.set("n", "<leader>ws", "<C-w>s", { noremap = true, silent = true, desc = "Split horizontally" })
keymap.set("n", "<leader>wh", "<C-w>h", { noremap = true, silent = true, desc = "Move right [<C-h>]" })
keymap.set("n", "<leader>wl", "<C-w>l", { noremap = true, silent = true, desc = "Move left [<C-l>]" })
keymap.set("n", "<leader>wj", "<C-w>j", { noremap = true, silent = true, desc = "Move down [<C-j>]" })
keymap.set("n", "<leader>wk", "<C-w>k", { noremap = true, silent = true, desc = "Move up [<C-k>]" })
keymap.set("n", "<leader>w=", "<cmd>vertical resize +10<cr>",
    { noremap = true, silent = true, desc = "Increase width" })
keymap.set("n", "<leader>w-", "<cmd>vertical resize -10<cr>",
    { noremap = true, silent = true, desc = "Decrease width" })

-- Shortcuts
keymap.set("n", "<C-h>", "<C-w>h", { noremap = true, silent = true })
keymap.set("n", "<C-l>", "<C-w>l", { noremap = true, silent = true })
keymap.set("n", "<C-j>", "<C-w>j", { noremap = true, silent = true })
keymap.set("n", "<C-k>", "<C-w>k", { noremap = true, silent = true })

keymap.set("v", "<", "<gv", { desc = "Indent left in visual mode" })
keymap.set("v", ">", ">gv", { desc = "Indent right in visual mode" })

-- Utillity key binding
------------------------------
keymap.set("i", "jk", "<ESC>", { noremap = true, silent = true })
keymap.set({ "i", "n" }, "<C-s>", "<ESC><CMD>:wa<CR>", { noremap = true, silent = true, desc = "Save session" })

keymap.set("n", "<leader>bC", function()
    local fullpath = vim.fn.bufname()
    if fullpath ~= nil and fullpath ~= "" then
        vim.cmd("let @+ = \'" .. fullpath .. "\'")
        print("Copied - " .. fullpath)
    end
end, { noremap = true, silent = true, desc = "Copy file path" })
keymap.set("n", "<leader>bc", function()
    local bufname = sys.get_curbuf_name()
    if bufname ~= nil and bufname ~= "" then
        vim.cmd("let @+ = \'" .. bufname .. "\'")
        print("Copied - " .. bufname)
    end
end, { noremap = true, silent = true, desc = "Copy file name" })
keymap.set("n", "<leader>bP", function()
    local bufdir = sys.get_curbuf_dir()
    if bufdir ~= nil and bufdir ~= "" then
        vim.cmd("let @+ = \'" .. bufdir .. "\'")
        print("Copied - " .. bufdir)
    end
end, { noremap = true, silent = true, desc = "Copy file directory path" })
-- Quickfix keymaps
------------------------------
-- Quick list management : For telescope C+q add search results to quick list.
keymap.set("n", "<leader>qo", ":copen<CR>", { noremap = true, silent = true, desc = "Open list" })
keymap.set("n", "<leader>qq", ":cclose<CR>", { noremap = true, silent = true, desc = "Close list" })
keymap.set("n", "<leader>qf", ":cfirst<CR>", { noremap = true, silent = true, desc = "Jump to first" })
keymap.set("n", "<leader>qn", ":cnext<CR>", { noremap = true, silent = true, desc = "Jump to next" })
keymap.set("n", "<leader>qp", ":cprev<CR>", { noremap = true, silent = true, desc = "Jump to prev" })
keymap.set("n", "<leader>ql", ":clast<CR>", { noremap = true, silent = true, desc = "Jump to last" })

-- Buffer management
-----------------------------------------------
keymap.set("n", "<leader>Q", ":bdelete<CR>", { noremap = true, silent = true, desc = "Close buffer" })
keymap.set("n", "<leader>bq", ":bdelete<CR>", { noremap = true, silent = true, desc = "Close [<Leader>Q]" })
keymap.set("n", "<leader>bn", ":bn<CR>", { noremap = true, silent = true, desc = "Move next [<Leader>Tab]" })
keymap.set("n", "<leader>bp", ":bp<CR>", { noremap = true, silent = true, desc = "Move prev" })

-- terminal management
--------------------------
keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { noremap = true, silent = true })
keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { noremap = true, silent = true })
keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { noremap = true, silent = true })
keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { noremap = true, silent = true })
keymap.set("n", "<C-t>", ":below terminal<CR>", { noremap = true, silent = true })
