local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require('luasnip.extras.fmt').fmt
local sys = require("core.util.sys")

local split = function(input_str, sep)
    local str_table = {}
    local len = 0
    for str in string.gmatch(input_str, "([^" .. sep .. "]+)") do
        table.insert(str_table, str)
        len = len + 1
    end
    return len, str_table
end

local get_file_and_pkg = function()
    local len, sub_paths = split(vim.fn.bufname(), "/")
    local pkg = ""
    local file_name = "file_name"
    local idx = -1
    for ii, value in pairs(sub_paths) do
        if ii < len then
            if value == "src" or value == "Src" or value == "SRC" then
                idx = 0
            elseif idx >= 0 then
                idx = idx + 1
                if idx == 1 and (value == "main" or value == "test") then
                elseif idx == 2 and (value == "java") then
                else
                    if pkg ~= "" then
                        pkg = pkg .. "."
                    end
                    pkg = pkg .. value
                end
            end
        else
            file_name = value
        end
    end
    return file_name, pkg
end

local function get_pkg()
    local _, pkg = get_file_and_pkg()
    if pkg == nil then
        return "package_name"
    end
    return pkg
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
    ]], { i(1, get_pkg()), i(2, sys.get_curbuf_name()), i(0), })),
})
