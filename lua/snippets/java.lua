local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require('luasnip.extras.fmt').fmt
local sys = require("core.util.sys")

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
    package {};

    import org.junit.Test;
    import org.junit.runner.RunWith;
    import org.mockito.junit.MockitoJUnitRunner;

    @RunWith(MockitoJUnitRunner.class)
    public class {} {{
        @Test
        public void test_name() {{
            {}
        }}
    }}
    ]], {i(1, "package_name"), i(2, sys.get_curbuf_name()), i(0), })),
})
