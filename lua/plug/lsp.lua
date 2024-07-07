return {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    dependencies = {
        "folke/lazydev.nvim",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",

        -- completion
        "hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        { "hrsh7th/nvim-cmp", event = { "InsertEnter", "CmdlineEnter" }, },

        -- snippet
        "saadparwaiz1/cmp_luasnip", -- Snippets source for nvim-cmp
        "L3MON4D3/LuaSnip",         -- Snippets plugin
        "rafamadriz/friendly-snippets",

        -- help format
        "onsails/lspkind.nvim",
    },
    config = function()
        require("lazydev").setup({})
        require("mason").setup({
            ui = {
                border = 'rounded',
                width = 0.7,
                height = 0.8,
            },
        })
        require('mason-tool-installer').setup({
            ensure_installed = {
                "lua_ls", "clangd", "pyright", "bashls",
                "jsonls", "yamlls", "dockerls", "jdtls",
                "tsserver", "quick_lint_js",
                "cssls", "clang-format",
                "prettier", "emmet-language-server",
                "java-debug-adapter", "java-test",
            },
        })
        vim.api.nvim_command('MasonToolsInstall')

        -- Define the diagnostic signs.
        local diagnostic_icons = {
            ERROR = 'x',
            WARN = '*',
            HINT = '*',
            INFO = '*',
        }
        for severity, icon in pairs(diagnostic_icons) do
            local hl = 'DiagnosticSign' .. severity:sub(1, 1) .. severity:sub(2):lower()
            vim.fn.sign_define(hl, { text = icon, texthl = hl })
        end

        local lsp_config = require("lspconfig")
        local mason_config = require("mason-lspconfig")
        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        mason_config.setup_handlers({
            function(server_name)
                if server_name == "yamlls" then
                    lsp_config[server_name].setup({
                        capabilities = capabilities,
                        settings = {
                            yaml = {
                                format = {
                                    enable = true,
                                    singleQuote = false,
                                    bracketSpacing = true
                                },
                                validate = false,
                                completion = true,
                            },
                        },
                    })
                elseif server_name == "lua_ls" then
                    lsp_config[server_name].setup({
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                diagnostics = {
                                    globals = { "vim" },
                                },
                            },
                        },
                    })
                elseif server_name ~= "jdtls" then
                    lsp_config[server_name].setup({
                        capabilities = capabilities,
                    })
                end
            end,
        })

        -- load snippet during lsp-attach event
        --------------------------------------
        local load_snippets = (function()
            local custo_snippet_path = vim.fn.stdpath("data") .. "/snippets/"
            local init_file_types = {}
            return function(file_type)
                local snippet_path = "lua/snippets/"
                if init_file_types[file_type] == nil then
                    for _, ft_path1 in ipairs(vim.api.nvim_get_runtime_file(snippet_path .. file_type .. "*.lua", true)) do
                        loadfile(ft_path1)()
                    end
                    for _, ft_path2 in ipairs(vim.split(vim.fn.glob(custo_snippet_path .. file_type .. "*.lua"), '\n', { trimempty = true })) do
                        loadfile(ft_path2)()
                    end
                    init_file_types[file_type] = true
                end
            end
        end)()

        -- Setup keymap for diagnostics
        ---------------------------------
        local diagnostics = vim.diagnostic
        vim.keymap.set("n", "<leader>dl", diagnostics.open_float, { desc = "Show diagnostics" })
        vim.keymap.set("n", "<leader>dp", diagnostics.goto_prev, { desc = "Previous diagnostics" })
        vim.keymap.set("n", "<leader>dn", diagnostics.goto_next, { desc = "Next diagnostics" })

        -- Use LspAttach autocommand to only map the following keys
        -- after the language server attaches to the current buffer
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(ev)
                -- Load user snippets
                -----------------------
                load_snippets(vim.bo.filetype)

                -- Define key bindings
                ----------------------
                local vim_lbuf = vim.lsp.buf

                -- Enable completion triggered by <c-x><c-o>
                vim.bo[ev.buf].omnifunc = "v:lua.vim_lsp.omnifunc"

                local lsp_buildin = require("telescope.builtin")
                vim.keymap.set("n", "<leader>Wa", vim_lbuf.add_workspace_folder,
                    { buffer = ev.buf, desc = "Add workspace folder" })
                vim.keymap.set("n", "<leader>Wr", vim_lbuf.remove_workspace_folder,
                    { buffer = ev.buf, desc = "Remove workspace folder" })
                vim.keymap.set("n", "<leader>Wl", function()
                    print(vim.inspect(vim_lbuf.list_workspace_folders()))
                end, { buffer = ev.buf, desc = "List workspace folders" })
                vim.keymap.set("n", "gD", vim_lbuf.declaration, { buffer = ev.buf, desc = "Go to declaration" })
                vim.keymap.set("n", "gd", vim_lbuf.definition, { buffer = ev.buf, desc = "Go to definition" })
                vim.keymap.set("n", "gi", vim_lbuf.implementation, { buffer = ev.buf, desc = "Go to implementation" })
                vim.keymap.set("n", "gr", lsp_buildin.lsp_references, { buffer = ev.buf, desc = "List references" })

                vim.keymap.set("n", "<leader>gl", lsp_buildin.lsp_document_symbols, { desc = "List document symbols" })
                vim.keymap.set("n", "<leader>gg", vim_lbuf.hover, { buffer = ev.buf, desc = "Hover" })
                vim.keymap.set("n", "<leader>gd", vim_lbuf.definition, { buffer = ev.buf, desc = "Go to definition" })
                vim.keymap.set("n", "<leader>gD", vim_lbuf.declaration, { buffer = ev.buf, desc = "Go to declaration" })
                vim.keymap.set("n", "<leader>gi", vim_lbuf.implementation,
                    { buffer = ev.buf, desc = "Go to implementation" })
                vim.keymap.set("n", "<leader>gt", vim_lbuf.type_definition,
                    { buffer = ev.buf, desc = "Go to type definition" })
                vim.keymap.set("n", "<leader>gr", lsp_buildin.lsp_references,
                    { buffer = ev.buf, desc = "List references" })
                vim.keymap.set("n", "<leader>gs", vim_lbuf.signature_help, { buffer = ev.buf, desc = "Signature help" })
                vim.keymap.set("n", "<leader>gR", vim_lbuf.rename, { buffer = ev.buf, desc = "Rename" })
                vim.keymap.set({ "n", "v" }, "<leader>ga", vim_lbuf.code_action,
                    { buffer = ev.buf, desc = "Code actions" })
                vim.keymap.set("n", "<leader>gf", function() vim.lsp.buf.format({ async = true }) end,
                    { buffer = ev.buf, desc = "Format code" })
            end,
        })

        -- luasnip setup
        local luasnip = require("luasnip")
        local snippet_loader = require("luasnip.loaders.from_vscode")
        snippet_loader.lazy_load();

        -- nvim-cmp setup
        local cmp = require("cmp")
        local lspkind = require("lspkind")
        cmp.setup({
            completion = {
                completeopt = "menu,menuone,preview,noselect",
            },
            formatting = {
                format = lspkind.cmp_format({
                    mode = "symbol", -- show only symbol annotations
                    maxwidth = 50,
                    ellipsis_char = "...",
                }),
                expandable_indicator = true,
            },
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
                ['<CR>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.confirm({ select = true, })
                    elseif luasnip.expandable() then
                        luasnip.expand()
                    else
                        fallback()
                    end
                end),
                ["<C-n>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<C-p>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.locally_jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<C-l>"] = cmp.mapping(function(fallback)
                    if luasnip.choice_active() then
                        luasnip.change_choice(1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
            }),

            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "path" },
            }, {
                { name = "buffer", keyword_length = 3 },
            }),
        })

        -- CMD completion setup
        ---------------------------
        -- 1) Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline({ "/", "?" }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = "buffer", keyword_length = 2 },
            },
        })

        -- 2) Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = "path" },
            }, {
                { name = "cmdline" },
            }),
        })

        -- UI setup : Added rounded border
        -- 1) Add border to lsp popup windows
        ------------------------------------
        require('lspconfig.ui.windows').default_options = {
            border = "rounded",
        }

        -- 2) Add border to popup window for signature
        ----------------------------------------------
        vim.lsp.util.open_floating_preview = (function()
            local open_floating_preview = vim.lsp.util.open_floating_preview
            return function(contents, syntax, opts, ...)
                opts = opts or {}
                opts.border = "rounded"
                return open_floating_preview(contents, syntax, opts, ...)
            end
        end)()
    end,
}
