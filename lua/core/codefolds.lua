local opt = vim.opt

opt.foldenable = false
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldtext = ""
opt.foldlevel = 99
opt.foldlevelstart = 1
opt.foldnestmax = 2
local fillchars = { fold = ' ', foldopen = '-', foldclose = '+', foldsep = ' ', }
local old_fillchars = vim.opt.fillchars:get()
local old_statuscolumn = vim.o.statuscolumn

local function get_fold(lnum)
    if vim.fn.foldlevel(lnum) <= vim.fn.foldlevel(lnum - 1) then return ' ' end
    return vim.fn.foldclosed(lnum) == -1 and fillchars.foldopen or fillchars.foldclose
end
_G.get_statuscol = function()
    return get_fold(vim.v.lnum) .. " %r %s"
end

vim.keymap.set("n", "<leader>E", function()
    if vim.o.foldenable == false then
        vim.opt.fillchars = fillchars
        vim.o.foldenable = true
        vim.o.foldcolumn = "1"
        vim.o.statuscolumn = "%!v:lua.get_statuscol()"
    else
        vim.opt.fillchars = old_fillchars
        vim.o.foldenable = false
        vim.o.foldcolumn = "0"
        vim.o.statuscolumn = old_statuscolumn
    end
end, { noremap = true, silent = true, desc = "Enable code folding" })

