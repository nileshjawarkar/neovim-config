local function setup_keys()
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
            require("config.lsp.cmp").load_snippets(vim.bo.filetype)

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
end


local function setup()
    require("lazydev").setup({})
    local lsp_config = require("lspconfig")
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    require("config.lsp.mason").setup({
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

    require("config.lsp.ui").setup()
    require("config.lsp.cmp").setup()
    setup_keys()
end

return {
    setup = setup,
}
