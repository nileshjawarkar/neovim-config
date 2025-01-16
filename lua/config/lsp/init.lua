
local setup_keymaps = function(ev)
    local first_time = require("core.util.sys").first_time
    if first_time.check("LspKeyInit") then
        -- This block will be executed only once
        -- Setup keymap for diagnostics
        ---------------------------------
        local diagnostics = vim.diagnostic
        vim.keymap.set("n", "<leader>dL", diagnostics.open_float, { desc = "Show diagnostics" })
        vim.keymap.set("n", "<leader>dp", diagnostics.goto_prev, { desc = "Previous diagnostics" })
        vim.keymap.set("n", "<leader>dn", diagnostics.goto_next, { desc = "Next diagnostics" })

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
        first_time.setFalse("LspKeyInit")
    end

    -- Load user snippets - once for each filetype
    ---------------------------------------------
    require("config.lsp.cmp").load_snippets(vim.bo.filetype)

    -- Define key bindings
    ----------------------
    local vim_lbuf = vim.lsp.buf

    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = "v:lua.vim_lsp.omnifunc"

    local lsp_buildin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>lwa", vim_lbuf.add_workspace_folder,
        { buffer = ev.buf, desc = "Add workspace folder" })
    vim.keymap.set("n", "<leader>lwr", vim_lbuf.remove_workspace_folder,
        { buffer = ev.buf, desc = "Remove workspace folder" })
    vim.keymap.set("n", "<leader>lwl", function()
        vim.notify(vim.inspect(vim_lbuf.list_workspace_folders()), vim.log.levels.INFO)
    end, { buffer = ev.buf, desc = "List workspace folders" })

    vim.keymap.set("n", "<leader>lD", vim_lbuf.declaration,
        { buffer = ev.buf, desc = "Go to declaration [<gD>]" })
    vim.keymap.set("n", "gD", vim_lbuf.declaration,
        { buffer = ev.buf, desc = "Go to declaration" })

    vim.keymap.set("n", "<leader>lt", vim_lbuf.type_definition,
        { buffer = ev.buf, desc = "Go to type definition [<gO>]" })
    vim.keymap.set("n", "gO", vim_lbuf.type_definition, { buffer = ev.buf, desc = "Go to type definition" })

    vim.keymap.set("n", "<leader>ld", vim_lbuf.definition, { buffer = ev.buf, desc = "Go to definition [<gd>]" })
    vim.keymap.set("n", "gd", vim_lbuf.definition, { buffer = ev.buf, desc = "Go to definition" })

    vim.keymap.set("n", "<leader>lI", lsp_buildin.lsp_implementations,
        { buffer = ev.buf, desc = "Go to implementation [<gI>]" })
    vim.keymap.set("n", "gI", lsp_buildin.lsp_implementations, { buffer = ev.buf, desc = "Go to implementation" })

    vim.keymap.set("n", "<leader>lr", lsp_buildin.lsp_references,
        { buffer = ev.buf, desc = "List references" })

    vim.keymap.set("n", "<leader>ll", lsp_buildin.lsp_document_symbols, { desc = "List document symbols" })

    vim.keymap.set("n", "<leader>lg", vim_lbuf.hover, { buffer = ev.buf, desc = "Hover [<gK>]" })
    vim.keymap.set("n", "gK", vim_lbuf.hover, { buffer = ev.buf, desc = "Hover" })

    vim.keymap.set("n", "<leader>ls", vim_lbuf.signature_help, { buffer = ev.buf, desc = "Signature help [<gs>]" })
    vim.keymap.set("n", "gs", vim_lbuf.signature_help, { buffer = ev.buf, desc = "Signature help" })

    vim.keymap.set("n", "<leader>lR", vim_lbuf.rename, { buffer = ev.buf, desc = "Rename" })
    vim.keymap.set({ "n", "v" }, "<leader>la", vim_lbuf.code_action,
        { buffer = ev.buf, desc = "Code actions" })
    vim.keymap.set("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end,
        { buffer = ev.buf, desc = "Format code" })

    vim.keymap.set("n", "<leader>lL", vim.ls.codelens.refresh,
        { buffer = ev.buf, desc = "Refresh Lsp" })

    -- Experimental
    vim.lsp.codelens.refresh()
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
        require("lazydev").setup({})
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
        require("config.lsp.cmp").setup()

        -- Use LspAttach autocommand to only map the following keys
        -- after the language server attaches to the current buffer
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = setup_keymaps,
        })
    end,
}
