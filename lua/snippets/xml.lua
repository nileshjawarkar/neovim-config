local mvn = require("core.mvn")
local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require('luasnip.extras.fmt').fmt

ls.add_snippets("xml", {
    s("pom_java", fmt(mvn.get_pom("java"), {
        i(1, "package"),
        i(2, "artifactId"),
        i(3, "version"),
        i(4, "project"),
        i(0),
    })),

    s("pom_javaee", fmt(mvn.get_pom("javaee"), {
        i(1, "package"),
        i(2, "artifactId"),
        i(3, "version"),
        i(4, "project"),
        i(0),
    })),

    s("pom_dep", fmt([[
<dependency>
    <groupId>{}</groupId>
    <artifactId>{}</artifactId>
    <version>{}</version>
    <scope>{}</scope>
</dependency>
    ]], {
        i(1),
        i(2),
        i(3),
        i(0),
    })),
})
