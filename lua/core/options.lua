vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local opt = vim.opt

opt.cmdheight = 1
opt.relativenumber = true -- Show relative line numbers
opt.number = true         -- Shows absolute line number on cursor line (when relative number is on)

-- Tabs & indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true  -- Expand tab to spaces
opt.autoindent = true -- Copy indent from current line when starting new one

-- Line wrapping
opt.wrap = false -- Disable line wrapping

-- Search settings
opt.hlsearch = false
opt.ignorecase = true -- Ignore case when searching
opt.smartcase = true  -- If you include mixed case in your search, assumes you want case-sensitive

opt.inccommand = "nosplit"

-- Highlight the current cursor line
opt.cursorline = true

-- Appearance Config

-- Turn on termguicolors for nightfly color scheme to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes"  -- show sign column so that text doesn't shift

-- Allow backspace on indent, end of line or insert mode start position
opt.backspace = "indent,eol,start"

-- Use system clipboard as default register
-- Schedule the setting after `UiEnter` because it can increase startup-time.
vim.schedule(function()
    vim.opt.clipboard = 'unnamedplus'
end)

-- Split windows
opt.splitright = true
opt.splitbelow = true

-- Turn off swapfile
opt.swapfile = false

opt.mouse = ""

-- Open completion menu even for single item
-- Do not auto insert items from completion menu
-- @warning - preview is removed. When it's on, default LSP opens a vertical tab
opt.completeopt = "menuone,noinsert,noselect"

-- Stop showing the current mode
opt.showmode = false
-- Stop showing the current line and cursor position in the status bar
opt.ruler = false

opt.inccommand = "nosplit"

-- Fold management
opt.foldenable = false
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.fillchars = { fold = ' ', }

_G.tabNameGen = function()
    return " " .. vim.fn.expand("%") .. " "
end
opt.tabline = "%!v:lua.tabNameGen()"

if vim.g.neovide then
    vim.o.guifont = "SauceCodePro Nerd Font:h12"
end

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})
