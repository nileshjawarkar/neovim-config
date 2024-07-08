local function set_diagnostic_icons()
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
end

local function setup()
    set_diagnostic_icons()

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
    setup = setup,
}
