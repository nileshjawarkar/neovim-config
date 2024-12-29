local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require('luasnip.extras.fmt').fmt
local sys = require("core.util.sys")
local str_util = require("core.util.string")

local get_file_and_pkg = function()
    local file_name, parent_path = sys.get_bufname_and_its_parent(false)
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
    return file_name, pkg
end

local function get_junit_moc_class_def()
    local filename, pkg = get_file_and_pkg()
    return [[
package ]] .. pkg .. [[;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.junit.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.class)
public class ]] .. filename .. [[ {{
    @Test
    public void test_name() {{
        {}
    }}
}}
]]
end

ls.add_snippets("java", {
    s("jtest", {
        t({ "@Test", "" }),
        t("public void "),
        i(1, "test_name"),
        t({ "(){", "\t" }),
        i(0),
        t({ "", "}" }),
    }),

    s("jclass", fmt(get_junit_moc_class_def(), { i(0), })),

    s("psf", {
        t("public static "),
        i(1, "String"),
        t(" "),
        i(2, "name"),
        t(";"),
        i(0)
    }),

    s("prf", {
        t("private "),
        i(1, "String"),
        t(" "),
        i(2, "name"),
        t(";"),
        i(0)
    }),

    s("prm", {
        t("private "),
        i(1, "void"),
        t( " " ),
        i(2, "name"),
        t({ "(){", "\t" }),
        i(0),
        t({ "", "}" }),
    }),

    s("pum", {
        t("public "),
        i(1, "void"),
        t( " " ),
        i(2, "name"),
        t({ "(){", "\t" }),
        i(0),
        t({ "", "}" }),
    }),

    s("psm", {
        t("public static"),
        i(1, "void"),
        t( " " ),
        i(2, "name"),
        t({ "(){", "\t" }),
        i(0),
        t({ "", "}" }),
    }),
})
