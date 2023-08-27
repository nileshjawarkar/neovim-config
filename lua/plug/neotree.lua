return {
   "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
        popup_border_style = "rounded",
      })

      vim.keymap.set("n", "<leader>tt", ":Neotree toggle<CR>")
      vim.keymap.set("n", "<leader>t.", ":Neotree reveal<CR>")
    end
}
