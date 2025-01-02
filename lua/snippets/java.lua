local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require('luasnip.extras.fmt').fmt
local f = ls.function_node
local sys = require("core.util.sys")
local str_util = require("core.util.string")

local get_pkg = function()
    local parent_path = sys.get_curbuf_dir()
    local pkg, idx = "", -1
    str_util.split(parent_path, sys.get_path_sep(), function(dir_name)
        if dir_name == "src" or dir_name == "Src" or dir_name == "SRC" then
            idx = 0
        elseif idx >= 0 then
            idx = idx + 1
            if idx == 1 and (dir_name == "main" or dir_name == "test") then
            elseif idx == 2 and (dir_name == "java") then
            else
                if pkg ~= "" then
                    pkg = pkg .. "."
                end
                pkg = pkg .. dir_name
            end
        end
    end)
    return pkg
end


local get_class = function()
    return sys.get_curbuf_name_without_ext()
end

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

ls.add_snippets("java", {
    s("jclass4", fmt(junit4_class_def, { pkg = f(get_pkg), name = f(get_class), test_name = i(1, "test_name"), last = i(0) })),
    s("jtest", fmt(jtest_method, { name = i(1, "test_name"), last = i(0) })),

    s("pusc", fmt(public_static_class, { name = i(1, "name"), last = i(0) })),
    s("prsc", fmt(private_static_class, { name = i(1, "name"), last = i(0) })),

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
