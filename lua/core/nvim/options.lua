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

-- Minimal number of screen lines to keep above and below the cursor.
opt.scrolloff = 10

opt.inccommand = "split"

-- Sets how neovim will display certain whitespace characters in the editor.
opt.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

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

-- Enable break indent
opt.breakindent = true
-- Turn off swapfile
opt.swapfile = false
-- Save undo history
opt.undofile = true
-- Decrease update time
vim.opt.updatetime = 250
-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 300

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
    vim.g.neovide_remember_window_size = true
    vim.g.neovide_text_gamma = 0.0
    vim.g.neovide_text_contrast = 0.5
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

-- Disable cursorline globally
vim.opt.cursorline = false

-- Automatically enable cursorline only in the active window
vim.api.nvim_create_autocmd("WinEnter", {
  pattern = "*",
  callback = function()
    vim.wo.cursorline = true
  end,
})

-- Disable cursorline when switching away from a window
vim.api.nvim_create_autocmd("WinLeave", {
  pattern = "*",
  callback = function()
    vim.wo.cursorline = false
  end,
})
