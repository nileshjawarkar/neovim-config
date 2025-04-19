local sys = require("core.util.sys")

local keymap = vim.keymap

-- Disable the spacebar key's default behavior in Normal and Visual modes
keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
-- delete single character without copying into register
keymap.set('n', 'x', '"_x', { noremap = true, silent = true })

keymap.set({'n', 'v'}, "<leader>N", "<cmd>enew<CR>", {noremap = true, silent = true, desc = "Open un-named buffer"})

-- Window management
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

keymap.set("i", "<C-h>", "<left>", { noremap = true, silent = true })
keymap.set("i", "<C-l>", "<right>", { noremap = true, silent = true })
keymap.set("i", "<C-j>", "<down>", { noremap = true, silent = true })
keymap.set("i", "<C-k>", "<up>", { noremap = true, silent = true })

-- Utillity key binding
keymap.set("i", "jk", "<ESC>", { noremap = true, silent = true })
keymap.set({ "i", "n" }, "<C-s>", "<ESC><CMD>:silent wa<CR>", { noremap = true, silent = true, desc = "Save session" })

keymap.set("n", "<leader>bC", function()
    local fullpath = vim.fn.bufname()
    if fullpath ~= nil and fullpath ~= "" then
        vim.cmd("let @+ = \'" .. fullpath .. "\'")
        vim.notify("Copied - " .. fullpath, vim.log.levels.INFO)
    end
end, { noremap = true, silent = true, desc = "Copy file path" })
keymap.set("n", "<leader>bc", function()
    local bufname = sys.get_curbuf_name()
    if bufname ~= nil and bufname ~= "" then
        vim.cmd("let @+ = \'" .. bufname .. "\'")
        vim.notify("Copied - " .. bufname, vim.log.levels.INFO)
    end
end, { noremap = true, silent = true, desc = "Copy file name" })
keymap.set("n", "<leader>bP", function()
    local bufdir = sys.get_curbuf_dir()
    if bufdir ~= nil and bufdir ~= "" then
        vim.cmd("let @+ = \'" .. bufdir .. "\'")
        vim.notify("Copied - " .. bufdir, vim.log.levels.INFO)
    end
end, { noremap = true, silent = true, desc = "Copy file directory path" })

-- Buffer management
keymap.set("n", "<leader>bq", ":bdelete<CR>", { noremap = true, silent = true, desc = "Close" })
keymap.set("n", "<leader>bn", ":bn<CR>", { noremap = true, silent = true, desc = "Move next" })
keymap.set("n", "<leader>bp", ":bp<CR>", { noremap = true, silent = true, desc = "Move prev" })
-- keymap.set("n", "<leader>bw", "<cmd>set wrap!<CR>", { noremap = true, silent = true, desc = "Toggle word-wrap" })

-- terminal management
keymap.set("t", "<ESC><ESC>", "<C-\\><C-n>", { noremap = true, silent = true })
keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { noremap = true, silent = true })
keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { noremap = true, silent = true })
keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { noremap = true, silent = true })
keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { noremap = true, silent = true })

keymap.set({ "n", "i", "v", "t" }, "<M-q>", function()
    require("config.handlers").closeThemForMe("any")
end, { noremap = true, silent = true })

-- code execution
keymap.set("n", "<leader>ss", "<cmd>source %<CR>", { noremap = true, silent = true, desc = "Execute lua file" })
keymap.set("n", "<leader>sx", ":.lua<CR>", { noremap = true, silent = true, desc = "Execute current line" })
keymap.set("v", "<leader>sx", ":lua<CR>", { noremap = true, silent = true, desc = "Execute selected lines" })
