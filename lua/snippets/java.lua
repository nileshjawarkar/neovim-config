local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require('luasnip.extras.fmt').fmt

local sys = require("core.util.sys")
local javart = require("core.rt.java")

local junit4_class_def = [[
package {pkg};

import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.junit.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.class)
public class {name} {{
    @Test
    public void {test_name}() {{
        {last}
    }}
}}
]]

local private_static_class = [[
private static class {name} {{
    {last}
}}
]]

local public_static_class = [[
public static class {name} {{
    {last}
}}
]]

local jtest_method = [[
@Test
public void {name}(){{
    {last}
}}
]]

local new_runnable = [[
new Runnable() {{
    @Override
    public void run() {{
        {last}
    }}
}}
]]

local public_runnable = [[
public static class {name} implements Runnable {{
    @Override
    public void run() {{
        {last}
    }}
}}
]]


ls.add_snippets("java", {
    s("jclass4",
        fmt(junit4_class_def,
            { pkg = f(javart.get_curbuf_as_pkg), name = f(sys.get_curbuf_name_without_ext), test_name = i(1, "test_name"), last =
            i(0) })),
    s("jtest", fmt(jtest_method, { name = i(1, "test_name"), last = i(0) })),

    s("pusc", fmt(public_static_class, { name = i(1, "name"), last = i(0) })),
    s("pusr", fmt(public_runnable, { name = i(1, "name"), last = i(0) })),
    s("prsc", fmt(private_static_class, { name = i(1, "name"), last = i(0) })),
    s("newrunnable", fmt(new_runnable, { last = i(0) })),

    s("prsf", {
        t("private static "),
        i(1, "String"),
        t(" "),
        i(2, "name"),
        t(";"),
        i(0)
    }),

    s("pusf", {
        t("public static "),
        i(1, "String"),
        t(" "),
        i(2, "name"),
        t(";"),
        i(0)
    }),

})
