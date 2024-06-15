local ls = require("luasnip")
local s = ls.snippet
-- local t = ls.text_node
local fmt = require('luasnip.extras.fmt').fmt
local i = ls.insert_node
-- local r = require("luasnip.extras").rep

ls.add_snippets("html", {
    s("bs_starter", fmt([[
     <!DOCTYPE html>
     <html lang="en">
     <head>
         <meta charset="UTF-8">
         <meta name="viewport" content="width=device-width, initial-scale=1.0">
         <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
         <title>{title}</title>
     </head>
     <body>
         {content}
         <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/umd/popper.min.js" integrity="sha384-I7E8VVD/ismYTF4hNIPjVp/Zjvgyol6VFvRkX/vR+Vc4jQkC+hVqc2pM8ODewa9r" crossorigin="anonymous"></script>
         <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.min.js" integrity="sha384-0pUGZvbkm6XF6gxjEnlmuGrJXVbNuzT9qBBavbLwCsOGabYfZo0T0to5eqruptLy" crossorigin="anonymous"></script>
     </body>
     </html>
     ]], { title = i(1, "Page Title"), content = i(2) }
    )),
    s("bs_container", fmt([[
<div class="container">
    {}
</div>
    ]], {i(1),})),
    s("bs_row", fmt([[
<div class="row">
    {}
</div>
    ]], {i(1),})),
    s("bs_col", fmt([[
<div class="col">
    {}
</div>
    ]], {i(1),}))
})
