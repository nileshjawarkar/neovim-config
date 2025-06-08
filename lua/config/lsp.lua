local setup_keymaps = function(event)
    local first_time = require("core.util.sys").first_time
    if first_time.check("LspKeyInit") then
        -- This block will be executed only once
        -- Delayed DAP setup and snippet loading based on file type

        -- Setup DAP
        local dap_conf = require("config.dap")
        if nil ~= dap_conf then
            dap_conf.setup_keys()
        end
        local ws_config = require("config.ws")
        if nil ~= ws_config then
            if ws_config.dap_setup ~= nil and type(ws_config.dap_setup) == "function" then
                ws_config.dap_setup()
            end
        end
        -- Load user snippets - once for each filetype
        require("config.cmp").load_snippets(vim.bo.filetype)
        first_time.setFalse("LspKeyInit")
    end

    -- Define key bindings
    ----------------------
    local vim_lbuf = vim.lsp.buf
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[event.buf].omnifunc = "v:lua.vim_lsp.omnifunc"

    local function keymap(m, key, handler, desc)
        vim.keymap.set(m, key, handler, { buffer = event.buf, silent = true, desc = desc })
    end


    local lsp_buildin = require("telescope.builtin")
    keymap("n", "<leader>lI", lsp_buildin.lsp_implementations, "Go to implementation [<gI>]")
    keymap("n", "gI", lsp_buildin.lsp_implementations, "Go to implementation")
    keymap("n", "<leader>lr", lsp_buildin.lsp_references, "List references")
    keymap("n", "<leader>ll", lsp_buildin.lsp_document_symbols, "List document symbols")
    keymap("n", "<leader>lD", vim_lbuf.declaration, "Go to declaration [<gD>]")
    keymap("n", "gD", vim_lbuf.declaration, "Go to declaration")
    keymap("n", "<leader>lt", vim_lbuf.type_definition, "Go to type definition [<gO>]")
    keymap("n", "gO", vim_lbuf.type_definition, "Go to type definition")

    keymap("n", "<leader>ld", vim_lbuf.definition, "Go to definition [<gd>]")
    keymap("n", "gd", vim_lbuf.definition, "Go to definition")

    keymap("n", "<leader>lg", vim_lbuf.hover, "Hover [<gK>]")
    keymap("n", "gK", vim_lbuf.hover, "Hover")
    keymap("n", "<leader>ls", vim_lbuf.signature_help, "Signature help [<gs>]")
    keymap("n", "gs", vim_lbuf.signature_help, "Signature help")
    keymap("n", "<leader>lR", vim_lbuf.rename, "Rename")
    keymap({ "n", "v" }, "<leader>la", vim_lbuf.code_action, "Code actions")
    keymap("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, "Format code")
    keymap("n", "<leader>lL", vim.lsp.codelens.refresh, "Refresh Lsp")
    keymap("n", "<leader>lWa", vim_lbuf.add_workspace_folder, "Add workspace folder")
    keymap("n", "<leader>lWr", vim_lbuf.remove_workspace_folder, "Remove workspace folder")
    keymap("n", "<leader>lWl", function()
        vim.notify(vim.inspect(vim_lbuf.list_workspace_folders()), vim.log.levels.INFO)
    end, "List workspace folders")

    vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('UserLspBufDetach', { clear = true }),
        callback = function(_)
            vim.lsp.buf.clear_references()
        end,
    })

    -- The following code creates a keymap to toggle inlay hints in your
    -- code, if the language server you are using supports them
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
        keymap("n", "<leader>lh", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
        end, 'Toggle inlay hints')
    end
end

local function configure_ui()
    vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = 'x ',
                [vim.diagnostic.severity.WARN] = '* ',
                [vim.diagnostic.severity.INFO] = '> ',
                [vim.diagnostic.severity.HINT] = '- ',
            },
        } or {},
        virtual_text = {
            source = 'if_many',
            spacing = 2,
            format = function(diagnostic)
                local diagnostic_message = {
                    [vim.diagnostic.severity.ERROR] = diagnostic.message,
                    [vim.diagnostic.severity.WARN] = diagnostic.message,
                    [vim.diagnostic.severity.INFO] = diagnostic.message,
                    [vim.diagnostic.severity.HINT] = diagnostic.message,
                }
                return diagnostic_message[diagnostic.severity]
            end,
        },
    }

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
end

return {
    setup = function()
        local capabilities = require('blink.cmp').get_lsp_capabilities()
        vim.lsp.config('*', {
            capabilities = capabilities,
        })

        vim.lsp.config('lua_ls', {
            filetypes = { 'lua' },
            root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },
            settings = {
                Lua = {
                    completion = {
                        callSnippet = 'Replace',
                    },
                },
            }
        })

        vim.lsp.config('yamlls', {
            filetypes = { 'yml', 'yaml' },
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
            }
        })

        require("mason-lspconfig").setup({
            ensure_installed = {}, -- installs via mason-tool-installer
            automatic_installation = false,
            automatic_enable = {
                exclude = {
                    "jdtls",
                },
            },
        })

        configure_ui()
        -- Setup keymap for diagnostics
        ---------------------------------
        vim.keymap.set("n", "<leader>dL", vim.diagnostic.open_float, { desc = "Show diagnostics" })
        vim.keymap.set("n", "<leader>dp", function()
            vim.diagnostic.jump({ count = -1, float = true })
        end, { desc = "Previous diagnostics" })

        vim.keymap.set("n", "<leader>dn", function()
            vim.diagnostic.jump({ count = 1, float = true })
        end, { desc = "Next diagnostics" })

        -- Use LspAttach autocommand to only map the following keys
        -- after the language server attaches to the current buffer
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspBufAttach", {}),
            callback = setup_keymaps,
        })
    end,
}
