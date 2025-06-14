local function setup()
    -- luasnip setup
    local luasnip = require("luasnip")
    local snippet_loader = require("luasnip.loaders.from_vscode")
    snippet_loader.lazy_load();

    -- nvim-cmp setup
    local cmp = require("cmp")
    local lspkind = require("lspkind")

    -- Define key handlers
    local function select_handler(fallback)
        if cmp.visible() then
            cmp.confirm({ select = true, })
        elseif luasnip.expandable() then
            luasnip.expand()
        else
            fallback()
        end
    end
    local function next_handler(fallback)
        if cmp.visible() then
            cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
        else
            fallback()
        end
    end
    local function prev_handler(fallback)
        if cmp.visible() then
            cmp.select_prev_item()
        elseif luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
        else
            fallback()
        end
    end
    local function choice_handler(fallback)
        if luasnip.choice_active() then
            luasnip.change_choice(1)
        else
            fallback()
        end
    end

    cmp.setup({
        completion = {
            completeopt = "menu,menuone,preview,noselect",
        },
        formatting = {
            format = lspkind.cmp_format({
                mode = "symbol", -- show only symbol annotations
                maxwidth = {
                    menu = 50,
                    abbr = 50
                },
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
            -- Manually trigger a completion from nvim-cmp.
            -- Generally you don't need this, because nvim-cmp will display
            -- completions whenever it has completion options available.
            ['<C-Space>'] = cmp.mapping.complete {},

            ["<C-l>"] = cmp.mapping(choice_handler),
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            -- group 1 : Vimified
            ['<C-y>'] = cmp.mapping(select_handler),
            ["<C-n>"] = cmp.mapping(next_handler),
            ["<C-p>"] = cmp.mapping(prev_handler),
            -- group 2 : Microsoft style
            ['<CR>'] = cmp.mapping(select_handler),
            ["<Tab>"] = cmp.mapping(next_handler),
            ["<S-Tab>"] = cmp.mapping(prev_handler),
        }),

        sources = cmp.config.sources({
            { name = 'lazydev', group_index = 0, },
            { name = "nvim_lsp" },
            { name = "luasnip" },
            { name = "buffer",  keyword_length = 2 },
            { name = "path" },
            { name = 'render-markdown' },
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
            { name = "cmdline"},
        }),
    })

end

local load_snippets = (function()
    local first_time = require("core.util.sys").first_time
    return function(file_type)
        if first_time.check(file_type) then
            local custo_snippet_path = vim.fn.stdpath("data") .. "/snippets/"
            local snippet_path = "lua/snippets/"
            for _, ft_path1 in ipairs(vim.api.nvim_get_runtime_file(snippet_path .. file_type .. "*.lua", true)) do
                loadfile(ft_path1)()
            end
            for _, ft_path2 in ipairs(vim.split(vim.fn.glob(custo_snippet_path .. file_type .. "*.lua"), '\n', { trimempty = true })) do
                loadfile(ft_path2)()
            end
            first_time.setFalse(file_type)
        end
    end
end)()

return {
    setup = setup,
    load_snippets = load_snippets,
}
