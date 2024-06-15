local ls = require("luasnip")

local s = ls.snippet
-- local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
-- local c = ls.choice_node
-- local d = ls.dynamic_node
-- local r = ls.restore_node

local function copy(args)
	return args[1]
end

ls.add_snippets("lua", {
	s("lf", {
		t("local function "),
		i(1, "fun_name"),
		t({"()", "\t"}),
		i(0),
		t({ "", "end" }),
	}),

	s("lreq", {
		t("local "),
		f(copy, 1),
		t(" = require(\""),
		i(1),
		t("\")"),
		i(0)
	})
})

