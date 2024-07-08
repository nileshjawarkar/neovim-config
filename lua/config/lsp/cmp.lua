local function setup()
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
end

local load_snippets = (function()
    local init_file_types = {}
    return function(file_type)
        local custo_snippet_path = vim.fn.stdpath("data") .. "/snippets/"
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

return {
    setup = setup,
    load_snippets = load_snippets,
}
