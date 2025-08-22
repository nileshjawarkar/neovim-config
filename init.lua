require("options")
require("keymaps")
require("autocommands")
require("core")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    require("plug.colorstheme"),
    require("plug.lualine"),
    require("plug.snacks"),
    require("plug.colorizer"),
    require("plug.dressing"),
    require("plug.whichkey"),
    require("plug.mason"),
    require("plug.treesitter"),
    require("plug.harpoon"),
    require("plug.telescope"),
    require("plug.neogit"),
    require("plug.markdown"),
    require("plug.conform"),
    require("plug.lint"),
    require("plug.blink_cmp"),
    -- require("plug.cmp"),
    require("plug.lsp"),
    require("plug.jdtls"),
    require("plug.lazydev"),
}, {
    ui = { border = 'rounded' },
    install = { colorscheme = { "tokyonight" }, },
    checker = { enabled = true, notify = false, },
    change_detection = { notify = false, },
})
