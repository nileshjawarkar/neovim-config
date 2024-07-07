local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

ls.add_snippets("lua", {
	s("lfun", {
        t("local function "),
        i(1, "name"),
        t("("),
        i(2, ""),
        t({ ")", "\t"}),
        i(0),
        t({ "", "end" }),
	}),

	s("fun", {
		t("function("),
        i(1, ""),
		t({")", "\t"}),
		i(2),
		t({ "", "end" }),
        i(0),
	}),

	s("lrequire", {
		t("local "),
		f(function (import_name)
            local parts = vim.split(import_name[1][1], ".", {plain = true})
            return (parts[#parts] and string.gsub(parts[#parts], "%-", "_")) or ""
		end, {1}),
		t(" = require(\""),
		i(1, "import.name"),
		t("\")"),
		i(0)
	})
})

