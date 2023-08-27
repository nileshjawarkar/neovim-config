return {
   "neovim/nvim-lspconfig",
   dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- completion
      'hrsh7th/nvim-cmp', -- Autocompletion plugin
      'hrsh7th/cmp-nvim-lsp', -- LSP source for nvim-cmp
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',

      -- snippet
      'saadparwaiz1/cmp_luasnip', -- Snippets source for nvim-cmp
      'L3MON4D3/LuaSnip', -- Snippets plugin

      -- format
      'onsails/lspkind.nvim'
   },
   config = function()
      local req_servers = {
         'pyright', 'clangd',
         'tsserver', 'cssls', 'dockerls', 'html', 'bashls',
         'jsonls', 'yamlls', 'lua_ls', 'emmet_ls'
      }

      require("mason").setup()
      local mason_config = require("mason-lspconfig")
      mason_config.setup({ ensure_installed = req_servers, })

      local lsp_config = require('lspconfig')
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      mason_config.setup_handlers({
         function(server_name)
            lsp_config[server_name].setup({
               capabilities = capabilities,
            })
         end,
         ["lua_ls"] = function ()
            lsp_config.lua_ls.setup({
               capabilities = capabilities,
               settings = {
                  Lua = {
                     diagnostics = {
                        globals = { "vim" }
                     }
                  }
               }
            })
         end
      })

      local vim_keymap = vim.keymap
      local vim_diagnostic = vim.diagnostic
      local vim_lsp = vim.lsp
      local vim_api = vim.api

      -- Global mappings.
      -- See `:help vim_diagnostic.*` for documentation on any of the below functions
      vim_keymap.set('n', '<space>e', vim_diagnostic.open_float)
      vim_keymap.set('n', '[d', vim_diagnostic.goto_prev)
      vim_keymap.set('n', ']d', vim_diagnostic.goto_next)
      vim_keymap.set('n', '<space>q', vim_diagnostic.setloclist)

      -- Use LspAttach autocommand to only map the following keys
      -- after the language server attaches to the current buffer
      vim_api.nvim_create_autocmd('LspAttach', {
        group = vim_api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          -- Enable completion triggered by <c-x><c-o>
          vim.bo[ev.buf].omnifunc = 'v:lua.vim_lsp.omnifunc'

          -- Buffer local mappings.
          -- See `:help vim_lsp.*` for documentation on any of the below functions
          local opts = { buffer = ev.buf }
          vim_keymap.set('n', 'gD', vim_lsp.buf.declaration, opts)
          vim_keymap.set('n', 'gd', vim_lsp.buf.definition, opts)
          vim_keymap.set('n', 'K', vim_lsp.buf.hover, opts)
          vim_keymap.set('n', 'gi', vim_lsp.buf.implementation, opts)
          vim_keymap.set('n', '<C-k>', vim_lsp.buf.signature_help, opts)
          vim_keymap.set('n', '<space>wa', vim_lsp.buf.add_workspace_folder, opts)
          vim_keymap.set('n', '<space>wr', vim_lsp.buf.remove_workspace_folder, opts)
          vim_keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim_lsp.buf.list_workspace_folders()))
          end, opts)
          vim_keymap.set('n', '<space>D', vim_lsp.buf.type_definition, opts)
          vim_keymap.set('n', '<space>rn', vim_lsp.buf.rename, opts)
          vim_keymap.set({ 'n', 'v' }, '<space>ca', vim_lsp.buf.code_action, opts)
          vim_keymap.set('n', 'gr', require("telescope.builtin").lsp_references, opts)
          vim_keymap.set('n', '<space>f', function()
            vim_lsp.buf.format { async = true }
          end, opts)
        end,
      })

      -- luasnip setup
      local luasnip = require 'luasnip'

      -- nvim-cmp setup
      local cmp = require 'cmp'
      cmp.setup {
         snippet = {
            expand = function(args)
               luasnip.lsp_expand(args.body)
            end,
         },
         window = {
            completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
         },
         mapping = cmp.mapping.preset.insert({
            ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Up
            ['<C-d>'] = cmp.mapping.scroll_docs(4), -- Down
            -- C-b (back) C-f (forward) for snippet placeholder navigation.
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<CR>'] = cmp.mapping.confirm {
               behavior = cmp.ConfirmBehavior.Replace,
               select = true,
            },
            ['<Tab>'] = cmp.mapping(function(fallback)
               if cmp.visible() then
                  cmp.select_next_item()
               elseif luasnip.expand_or_jumpable() then
                  luasnip.expand_or_jump()
               else
                  fallback()
               end
            end, { 'i', 's' }),
            ['<S-Tab>'] = cmp.mapping(function(fallback)
               if cmp.visible() then
                  cmp.select_prev_item()
               elseif luasnip.jumpable(-1) then
                  luasnip.jump(-1)
               else
                  fallback()
               end
            end, { 'i', 's' }),
         }),

         sources = cmp.config.sources({
               { name = 'nvim_lsp' },
               { name = 'luasnip' },
            }, {
               { name = 'buffer', keyword_length = 3 },
         }),
      }

      -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline({ '/', '?' }, {
         mapping = cmp.mapping.preset.cmdline(),
         sources = {
            { name = 'buffer', keyword_length = 3 }
         }
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(':', {
         mapping = cmp.mapping.preset.cmdline(),
         sources = cmp.config.sources({
            { name = 'path' }
         }, {
            { name = 'cmdline' }
         })
      })

      local lspkind = require('lspkind')
      cmp.setup {
        formatting = {
          format = lspkind.cmp_format({
            mode = 'symbol', -- show only symbol annotations
            maxwidth = 50,
            ellipsis_char = '...',
          })
        }
      }

   end
}

