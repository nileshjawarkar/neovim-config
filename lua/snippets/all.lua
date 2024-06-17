local ls = require("luasnip")
local s = ls.snippet
local f = ls.function_node

ls.add_snippets("all", {
    s("curdate", f(function ()
        return os.date("%d-%m-%y")
    end)),
    s("curdatetime", f(function ()
        return os.date("%d-%m-%y %H:%M:%S")
    end)),
})
