require("options")
require("keymaps")
require("core")

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
---@diagnostic disable-next-line: undefined-field
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
    if vim.v.shell_error ~= 0 then
        error('Error cloning lazy.nvim:\n' .. out)
    end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    require("plug.colorstheme"),
    require("plug.snacks"),
    require("plug.colorizer"),
    require("plug.lualine"),
    require("plug.dressing"),
    require("plug.whichkey"),
    require("plug.treesitter"),
    require("plug.harpoon"),
    require("plug.telescope"),
    require("plug.neogit"),
    require("plug.markdown"),
    -- require("plug.blink_cmp"),
    require("plug.cmp"),
    require("plug.conform"),
    require("plug.lint"),
    require("plug.lsp"),
    require("plug.dap"),
    require("plug.jdtls"),
    require("plug.other"),
}, {
    ui = { border = 'rounded' },
    install = {
        colorscheme = { "tokyonight" },
    },
    checker = {
        enabled = true,
        notify = false,
    },
    change_detection = {
        notify = false,
    },
})
