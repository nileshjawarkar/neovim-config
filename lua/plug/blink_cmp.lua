return {
    "saghen/blink.cmp",
    event = "VimEnter",
    version = "1.*",
    dependencies = {
        {
            "L3MON4D3/LuaSnip",
            version = "2.*",
            build = (function()
                if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
                    return
                end
                return "make install_jsregexp"
            end)(),
            dependencies = {
                {
                    "rafamadriz/friendly-snippets",
                    config = function()
                        require("luasnip.loaders.from_vscode").lazy_load()
                    end,
                },
            },
            opts = {},
        },
        "folke/lazydev.nvim",
    },
    opts = {
        keymap = {
            ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
            ["<C-e>"]     = { "hide" },
            ["<C-y>"]     = { "select_and_accept", "fallback" },
            ['<CR>']      = { "select_and_accept", "fallback" },

            ["<C-p>"]     = { "select_prev", "fallback_to_mappings" },
            ["<C-n>"]     = { "select_next", "fallback_to_mappings" },

            ["<C-b>"]     = { "scroll_documentation_up", "fallback" },
            ["<C-f>"]     = { "scroll_documentation_down", "fallback" },

            ["<Down>"]    = { "select_next", "snippet_forward", "fallback" },
            ["<Up>"]      = { "select_prev", "snippet_backward", "fallback" },
            ["<Tab>"]     = { "select_next", "snippet_forward", "fallback" },
            ["<S-Tab>"]   = { "select_prev", "snippet_backward", "fallback" },

            ["<C-k>"]     = { "show_signature", "hide_signature", "fallback" },
        },
        appearance = {
            nerd_font_variant = "mono",
        },
        completion = {
            documentation = { auto_show = false },
            ghost_text = { enabled = true },
            list = { selection = { preselect = false, auto_insert = true } },
            menu = {
                border = "rounded",
            },
        },
        sources = {
            default = { "lsp", "buffer", "snippets", "path", "lazydev", "cmdline" },
            providers = {
                lsp = {
                    min_keyword_length = 0, -- Number of characters to trigger porvider
                    score_offset = 0, -- Boost/penalize the score of the items
                },
                path = {
                    min_keyword_length = 1,
                },
                snippets = {
                    min_keyword_length = 1,
                },
                buffer = {
                    min_keyword_length = 1,
                    max_items = 5,
                },
                lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
            },
        },
        snippets = { preset = "luasnip" },
        fuzzy = { implementation = "lua" },
        signature = {
            enabled = true,
            window = { border = "rounded" },
        },
    },
}
