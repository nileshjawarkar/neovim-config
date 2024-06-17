local ls = require("luasnip")
local s = ls.snippet
local f = ls.function_node
local fmt = require('luasnip.extras.fmt').fmt
local i = ls.insert_node
local r = require("luasnip.extras").rep


ls.add_snippets("all", {
    s("curdate", f(function ()
        return os.date("%d-%m-%y")
    end)),
    s("curdatetime", f(function ()
        return os.date("%d-%m-%y %H:%M:%S")
    end)),
})
