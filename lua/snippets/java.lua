local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require('luasnip.extras.fmt').fmt

ls.add_snippets("java", {
    s("jtest", {
        t({"@Test", ""}),
        t("public void "),
        i(1, "test_name"),
        t({ "(){", "\t" }),
        i(0),
        t({ "", "}" }),
    }),

    s("jclass", fmt([[
    import org.junit.Test;
    import org.junit.runner.RunWith;
    import org.mockito.junit.MockitoJUnitRunner;

    @RunWith(MockitoJUnitRunner.class)
    public class {} {{
        {}
    }}
    ]], {i(1, "class_name"), i(0), })),
})
