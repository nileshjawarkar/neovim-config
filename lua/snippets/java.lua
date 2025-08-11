local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require('luasnip.extras.fmt').fmt

local sys = require("core.util.sys")
local javart = require("core.rt.java")

-- Function to generate builder pattern based on current class fields
local function generate_builder()
    local success, result = pcall(function()
        local bufnr = vim.api.nvim_get_current_buf()
        local filetype = vim.bo[bufnr].filetype

        if filetype ~= 'java' then
            return { "// Error: Not a Java file" }
        end

        if not vim.treesitter.get_parser then
            return { "// Error: Tree-sitter not available" }
        end

        local parser = vim.treesitter.get_parser(bufnr, 'java')
        if not parser then
            return { "// Error: Java parser not available. Try :TSInstall java" }
        end

        local trees = parser:parse()
        if not trees or #trees == 0 then
            return { "// Error: Could not parse Java file" }
        end

        local tree = trees[1]
        local root = tree:root()

        local query = vim.treesitter.query.parse('java', [[
            (field_declaration
              type: (_) @type
              declarator: (variable_declarator
                name: (identifier) @name
              )
            )
        ]])

        local fields = {}
        local current_field = {}

        for id, node in query:iter_captures(root, bufnr, 0, -1) do
            local capture_name = query.captures[id]
            if capture_name then
                local text = vim.treesitter.get_node_text(node, bufnr)
                if capture_name == "type" then
                    current_field = { type = text }
                elseif capture_name == "name" then
                    if current_field.type then
                        current_field.name = text
                        table.insert(fields, current_field)
                        current_field = {}
                    end
                end
            end
        end

        if #fields == 0 then
            return { "// No fields found in this Java class" }
        end

        local class_name = sys.get_curbuf_name_without_ext() or "TestClass"
        local builder_name = class_name .. "Builder"

        local lines = {}
        table.insert(lines, "public static class " .. builder_name .. " {")

        -- Add field declarations
        for _, field in ipairs(fields) do
            if field.type and field.name then
                table.insert(lines, "    private " .. field.type .. " " .. field.name .. ";")
            end
        end

        table.insert(lines, "")

        -- Add setter methods
        for _, field in ipairs(fields) do
            if field.type and field.name then
                local capitalized = field.name:sub(1, 1):upper() .. field.name:sub(2)
                table.insert(lines,
                    "    public " ..
                    builder_name .. " with" .. capitalized .. "(" .. field.type .. " " .. field.name .. ") {")
                table.insert(lines, "        this." .. field.name .. " = " .. field.name .. ";")
                table.insert(lines, "        return this;")
                table.insert(lines, "    }")
                table.insert(lines, "")
            end
        end

        -- Add build method
        table.insert(lines, "    public " .. class_name .. " build() {")
        table.insert(lines, "        return new " .. class_name .. "(this);")
        table.insert(lines, "    }")
        table.insert(lines, "}")
        table.insert(lines, "")

        -- Add static factory method
        table.insert(lines, "public static " .. builder_name .. " builder() {")
        table.insert(lines, "    return new " .. builder_name .. "();")
        table.insert(lines, "}")
        table.insert(lines, "")

        -- Add private constructor
        table.insert(lines, "private " .. class_name .. "(" .. builder_name .. " builder) {")
        for _, field in ipairs(fields) do
            if field.type and field.name then
                table.insert(lines, "    this." .. field.name .. " = builder." .. field.name .. ";")
            end
        end
        table.insert(lines, "}")

        return lines
    end)

    if not success then
        return { "// Error generating builder: " .. tostring(result) }
    end

    return result
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

local public_thread = [[
public static class {name} extends Thread {{
    @Override
    public void run() {{
        {last}
    }}
}}
]]

ls.add_snippets("java", {
    s("jclass4",
        fmt(junit4_class_def,
            {
                pkg = f(javart.get_curbuf_as_pkg),
                name = f(sys.get_curbuf_name_without_ext),
                test_name = i(1, "test_name"),
                last =
                    i(0)
            })),
    s("jtest", fmt(jtest_method, { name = i(1, "test_name"), last = i(0) })),

    s("psc", fmt(public_static_class, { name = i(1, "name"), last = i(0) })),
    s("prsc", fmt(private_static_class, { name = i(1, "name"), last = i(0) })),
    s("psrun", fmt(public_runnable, { name = i(1, "name"), last = i(0) })),
    s("psthread", fmt(public_thread, { name = i(1, "name"), last = i(0) })),
    s("newrun", fmt(new_runnable, { last = i(0) })),

    s("prsif", {
        t("private static "),
        i(1, "int"),
        t(" "),
        i(2, "name"),
        t(";"),
        i(0)
    }),

    s("prssf", {
        t("private static "),
        i(1, "String"),
        t(" "),
        i(2, "name"),
        t(";"),
        i(0)
    }),

    s("psif", {
        t("public static "),
        i(1, "int"),
        t(" "),
        i(2, "name"),
        t(";"),
        i(0)
    }),

    s("pssf", {
        t("public static "),
        i(1, "String"),
        t(" "),
        i(2, "name"),
        t(";"),
        i(0)
    }),

    s("logg", {
        t("private static final Logger LOGGER = LoggerFactory.getLogger("),
        i(1, "class-name"),
        t(");"),
        i(0)
    }),

    s("serversion", {
        t("private static final long serialVersionUID = "),
        i(1, "11111"),
        t("L;"),
        i(0)
    }),

    s("builder", {
        f(generate_builder),
        i(0)
    }),
})
