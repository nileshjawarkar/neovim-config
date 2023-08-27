return {
   'nvim-telescope/telescope.nvim',
   tag = '0.1.2',
   dependencies = {
      'nvim-lua/plenary.nvim'
   },
   config = function()
      local actions = require('telescope.actions')
      require('telescope').setup {
         defaults = {
            prompt_prefix = ' > ',
            mappings = {
               i = {
                  ["jk"] = actions.close,
               },
            },
            set_env = { ['COLORTERM'] = 'truecolor' },
         },

         pickers = {
            find_files = {
               previewer = false,
               disable_devicons = true
            },
            live_grep = {
               disable_devicons = true
            },
            buffers = {
               sort_lastused = true,
               disable_devicons = true,
               previewer = false,
            }
         }
      }

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
   end
}
