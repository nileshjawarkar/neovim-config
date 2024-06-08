return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",

		-- completion
		"hrsh7th/nvim-cmp", -- Autocompletion plugin
		"hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",

		-- snippet
		"saadparwaiz1/cmp_luasnip", -- Snippets source for nvim-cmp
		"L3MON4D3/LuaSnip", -- Snippets plugin

		-- help format
		"onsails/lspkind.nvim",
	},
	config = function()
		local req_servers = {
			"lua_ls",
			"clangd",
			"pyright",
			"bashls",
			"jsonls",
			"yamlls",
			"jdtls",
			"tsserver",
			"quick_lint_js",
			"html",
			"cssls",
		}

		require("mason").setup()
		local mason_config = require("mason-lspconfig")
		local lsp_config = require("lspconfig")
		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		mason_config.setup({ ensure_installed = req_servers })
		mason_config.setup_handlers({
			function(server_name)
				lsp_config[server_name].setup({
					capabilities = capabilities,
				})
			end,
			["lua_ls"] = function()
				lsp_config.lua_ls.setup({
					capabilities = capabilities,
					settings = {
						Lua = {
							diagnostics = {
								globals = { "vim" },
							},
						},
					},
				})
			end,
		})

		local keymap = vim.keymap
		local diagnostics = vim.diagnostic
		local vim_lbuf = vim.lsp.buf
		local vim_api = vim.api

		-- Use LspAttach autocommand to only map the following keys
		-- after the language server attaches to the current buffer
		vim_api.nvim_create_autocmd("LspAttach", {
			group = vim_api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				-- Enable completion triggered by <c-x><c-o>
				vim.bo[ev.buf].omnifunc = "v:lua.vim_lsp.omnifunc"

				local lsp_buildin = require("telescope.builtin")
				local opts = { buffer = ev.buf, desc = "" }
				keymap.set("n", "<leader>Wa", vim_lbuf.add_workspace_folder, opts)
				keymap.set("n", "<leader>Wr", vim_lbuf.remove_workspace_folder, opts)
				keymap.set("n", "<leader>Wl", function()
					print(vim.inspect(vim_lbuf.list_workspace_folders()))
				end, opts)
				keymap.set("n", "gD", vim_lbuf.declaration, opts)
				keymap.set("n", "gd", vim_lbuf.definition, opts)
				keymap.set("n", "gi", vim_lbuf.implementation, opts)
				keymap.set("n", "gr", lsp_buildin.lsp_references, opts)

				keymap.set("n", "<leader>go", lsp_buildin.lsp_document_symbols, { desc = "List document symbols" })
				keymap.set("n", "<leader>gg", vim_lbuf.hover, { buffer = ev.buf, desc = "Hover" })
				keymap.set("n", "<leader>gd", vim_lbuf.definition, { buffer = ev.buf, desc = "Go to definition" })
				keymap.set("n", "<leader>gD", vim_lbuf.declaration, { buffer = ev.buf, desc = "Go to declaration" })
				keymap.set("n", "<leader>gi", vim_lbuf.implementation, { buffer = ev.buf, desc = "Go to implementation" })
				keymap.set("n", "<leader>gt", vim_lbuf.type_definition, { buffer = ev.buf, desc = "Go to type definition" })
				keymap.set("n", "<leader>gr", lsp_buildin.lsp_references, { buffer = ev.buf, desc = "List references" })
				keymap.set("n", "<leader>gs", vim_lbuf.signature_help, { buffer = ev.buf, desc = "Signature help" })
				keymap.set("n", "<leader>gR", vim_lbuf.rename, { buffer = ev.buf, desc = "Rename" })
				keymap.set({ "n", "v" }, "<leader>ga", vim_lbuf.code_action, { buffer = ev.buf, desc = "Code actions" })
				keymap.set("i", "<C-Space>", vim_lbuf.completion, { buffer = ev.buf, desc = "Code completion" })
				keymap.set("n", "<leader>gl", diagnostics.open_float, { buffer = ev.buf, desc = "Show diagnostics" })
				keymap.set("n", "<leader>gp", diagnostics.goto_prev, { buffer = ev.buf, desc = "Previous diagnostics" })
				keymap.set("n", "<leader>gn", diagnostics.goto_next, { buffer = ev.buf, desc = "Next diagnostics" })
				keymap.set("n", "<leader>gf", function()
					lsp_buildin.treesitter({ default_text = ":field:" })
				end, { desc = "Treesitter find" })

				-- Filetype-specific keymaps (these can be done in the ftplugin directory instead if you prefer)
				-- keymap.set("n", "<leader>gO", function()
				--     if vim.bo.filetype == "java" then
				--         require("jdtls").organize_imports()
				--     end
				-- end, { desc = "Organize imports" })

				-- keymap.set("n", "<leader>gu", function()
				--     if vim.bo.filetype == "java" then
				--         require("jdtls").update_projects_config()
				--     end
				-- end, { desc = "Update project config" })
			end,
		})

		-- luasnip setup
		local luasnip = require("luasnip")

		-- nvim-cmp setup
		local cmp = require("cmp")
		cmp.setup({
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
				["<C-u>"] = cmp.mapping.scroll_docs(-4), -- Up
				["<C-d>"] = cmp.mapping.scroll_docs(4), -- Down
				-- C-b (back) C-f (forward) for snippet placeholder navigation.
				["<C-leader>"] = cmp.mapping.complete(),
				["<CR>"] = cmp.mapping.confirm({
					behavior = cmp.ConfirmBehavior.Replace,
					select = true,
				}),
				["<Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					elseif luasnip.expand_or_jumpable() then
						luasnip.expand_or_jump()
					else
						fallback()
					end
				end, { "i", "s" }),
				["<S-Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					elseif luasnip.jumpable(-1) then
						luasnip.jump(-1)
					else
						fallback()
					end
				end, { "i", "s" }),
			}),

			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "luasnip" },
			}, {
				{ name = "buffer", keyword_length = 3 },
			}),
		})

		-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
		cmp.setup.cmdline({ "/", "?" }, {
			mapping = cmp.mapping.preset.cmdline(),
			sources = {
				{ name = "buffer", keyword_length = 3 },
			},
		})

		-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
		cmp.setup.cmdline(":", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = cmp.config.sources({
				{ name = "path" },
			}, {
				{ name = "cmdline" },
			}),
		})

		local lspkind = require("lspkind")
		cmp.setup({
			formatting = {
				format = lspkind.cmp_format({
					mode = "symbol", -- show only symbol annotations
					maxwidth = 50,
					ellipsis_char = "...",
				}),
			},
		})

        -- Globally configure all LSP floating preview popups (like hover, signature help, etc)
        local open_floating_preview = vim.lsp.util.open_floating_preview
        function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
          opts = opts or {}
          opts.border = opts.border or "rounded" -- Set border to rounded
          return open_floating_preview(contents, syntax, opts, ...)
        end
	end,
}
