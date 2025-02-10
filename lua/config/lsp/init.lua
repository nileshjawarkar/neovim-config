local setup_keymaps = function(ev)
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
    vim.bo[ev.buf].omnifunc = "v:lua.vim_lsp.omnifunc"

    local lsp_buildin = require("telescope.builtin")
    local function keymap(m, key, handler, desc)
        vim.keymap.set(m, key, handler, { buffer = ev.buf, silent = true, desc = desc })
    end

    keymap("n", "<leader>lD", vim_lbuf.declaration, "Go to declaration [<gD>]")
    keymap("n", "gD", vim_lbuf.declaration, "Go to declaration")
    keymap("n", "<leader>lt", vim_lbuf.type_definition, "Go to type definition [<gO>]")
    keymap("n", "gO", vim_lbuf.type_definition, "Go to type definition")
    keymap("n", "<leader>ld", vim_lbuf.definition, "Go to definition [<gd>]")
    keymap("n", "gd", vim_lbuf.definition, "Go to definition")
    keymap("n", "<leader>lI", lsp_buildin.lsp_implementations, "Go to implementation [<gI>]")
    keymap("n", "gI", lsp_buildin.lsp_implementations, "Go to implementation")
    keymap("n", "<leader>lr", lsp_buildin.lsp_references, "List references")
    keymap("n", "<leader>ll", lsp_buildin.lsp_document_symbols, "List document symbols")
    keymap("n", "<leader>lg", vim_lbuf.hover, "Hover [<gK>]")
    keymap("n", "gK", vim_lbuf.hover, "Hover")
    keymap("n", "<leader>ls", vim_lbuf.signature_help, "Signature help [<gs>]")
    keymap("n", "gs", vim_lbuf.signature_help, "Signature help")
    keymap("n", "<leader>lR", vim_lbuf.rename, "Rename")
    keymap({ "n", "v" }, "<leader>la", vim_lbuf.code_action, "Code actions")
    keymap("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, "Format code")
    keymap("n", "<leader>lL", vim.lsp.codelens.refresh, "Refresh Lsp")
    keymap("n", "<leader>lwa", vim_lbuf.add_workspace_folder, "Add workspace folder")
    keymap("n", "<leader>lwr", vim_lbuf.remove_workspace_folder, "Remove workspace folder")
    keymap("n", "<leader>lwl", function()
        vim.notify(vim.inspect(vim_lbuf.list_workspace_folders()), vim.log.levels.INFO)
    end, "List workspace folders")
end

local function configure_ui()
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
        local lsp_config = require("lspconfig")
        local root_dir = require("core.util.sys").find_root
        local ws_config = require("config.ws").lsp_config

        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

        require("config.lsp.mason").setup({
            function(server_name)
                local conf = ws_config ~= nil and ws_config[server_name] or nil
                local srv_config = {
                    capabilities = capabilities,
                    root_dir = root_dir,
                }

                if conf ~= nil then
                    if conf["cmd"] ~= nil then
                        srv_config["cmd"] = conf["cmd"]
                    end
                end

                if server_name == "yamlls" then
                    srv_config["settings"] = {
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
                elseif server_name == "lua_ls" then
                    require("lazydev").setup({})
                    srv_config["settings"] = {
                        Lua = {
                            diagnostics = { globals = { "vim" }, },
                        },
                    }
                end

                if server_name ~= "jdtls" then
                    lsp_config[server_name].setup(srv_config)
                end
            end,
        })

        configure_ui()

        -- Setup keymap for diagnostics
        ---------------------------------
        local diagnostics = vim.diagnostic
        vim.keymap.set("n", "<leader>dL", diagnostics.open_float, { desc = "Show diagnostics" })
        vim.keymap.set("n", "<leader>dp", diagnostics.goto_prev, { desc = "Previous diagnostics" })
        vim.keymap.set("n", "<leader>dn", diagnostics.goto_next, { desc = "Next diagnostics" })

        -- Use LspAttach autocommand to only map the following keys
        -- after the language server attaches to the current buffer
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspBufAttach", {}),
            callback = setup_keymaps,
        })

        vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('UserLspBufDettach', { clear = true }),
            callback = function(_)
                vim.lsp.buf.clear_references()
            end,
        })
    end,
}
