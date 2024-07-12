local opt = vim.opt     -- for conciseness

opt.cmdheight = 1
-- line numbers
opt.relativenumber = true     -- show relative line numbers
opt.number = true             -- shows absolute line number on cursor line (when relative number is on)

-- tabs & indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true      -- expand tab to spaces
opt.autoindent = true     -- copy indent from current line when starting new one

-- line wrapping
opt.wrap = false     -- disable line wrapping

-- search settings
opt.hlsearch = false
opt.ignorecase = true     -- ignore case when searching
opt.smartcase = true      -- if you include mixed case in your search, assumes you want case-sensitive

opt.inccommand = "nosplit"

-- cursor line
opt.cursorline = true     -- highlight the current cursor line

-- appearance

-- turn on termguicolors for nightfly colorscheme to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
opt.background = "dark"     -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes"      -- show sign column so that text doesn't shift

-- backspace
opt.backspace = "indent,eol,start"     -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus")     -- use system clipboard as default register

-- split windows
opt.splitright = true     -- split vertical window to the right
opt.splitbelow = true     -- split horizontal window to the bottom

-- turn off swapfile
opt.swapfile = false

opt.mouse = ""

-- open completion menu even for single item
-- do not auto insert items from completion menu
-- @warning - preview is removed. when it's on, default lsp opens a vertical tab
opt.completeopt = "menuone,noinsert,noselect"

-- stop showing the current mode
opt.showmode = false
-- stop showing the current line and cursor position in the status bar
opt.ruler = false

opt.inccommand = "nosplit"
