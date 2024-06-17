local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local c = ls.choice_node
local fmt = require('luasnip.extras.fmt').fmt
local i = ls.insert_node
local r = require("luasnip.extras").rep

ls.add_snippets("html", {
    s("bs_starter", fmt([[
     <!DOCTYPE html>
     <html lang="en">
     <head>
         <meta charset="UTF-8">
         <meta name="viewport" content="width=device-width, initial-scale=1.0">
         <title>Page title</title>
         <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
         <link href="css/style.css" rel="stylesheet" >
     </head>
     <body>
         {}
         <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/umd/popper.min.js" integrity="sha384-I7E8VVD/ismYTF4hNIPjVp/Zjvgyol6VFvRkX/vR+Vc4jQkC+hVqc2pM8ODewa9r" crossorigin="anonymous"></script>
         <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.min.js" integrity="sha384-0pUGZvbkm6XF6gxjEnlmuGrJXVbNuzT9qBBavbLwCsOGabYfZo0T0to5eqruptLy" crossorigin="anonymous"></script>
         <script src="js/script.js"></script>
     </body>
     </html>
     ]], { i(0) }
    )),
    s("bs_navbar", fmt([[
<nav class="navbar navbar-expand-lg bg-body-tertiary">
  <div class="container-fluid">
    <a class="navbar-brand" href="#">Navbar</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarSupportedContent">
      <ul class="navbar-nav me-auto mb-2 mb-lg-0">
        <li class="nav-item">
          <a class="nav-link active" aria-current="page" href="#">Home</a>
        </li>
        {}
      </ul>
    </div>
  </div>
</nav>
    ]], { i(0), })),
    s("bs_nav_item", fmt([[
<li class="nav-item">
  <a class="nav-link" href="#">{}</a>
</li>
    ]], {i(0), })),
    s("bs_nav_item_disabled", fmt([[
<li class="nav-item">
  <a class="nav-link disabled" aria-disabled="true">{}</a>
</li>
    ]], { i(0), })),
    s("bs_nav_item_dropdown", fmt([[
<li class="nav-item dropdown">
  <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
    Dropdown
  </a>
  <ul class="dropdown-menu">
    <li><a class="dropdown-item" href="#">Action</a></li>
    <li><a class="dropdown-item" href="#">Another action</a></li>
    <li><hr class="dropdown-divider"></li>
    <li><a class="dropdown-item" href="#">Something else here</a></li>
  </ul>
</li>
    ]], {})),
    s("bs_container", fmt([[
<div class="{}">{}</div>
    ]], {
        c(1, { t("container"),
            t("container-sm"),
            t("container-md"),
            t("container-lg"),
            t("container-xl"),
            t("container-xxl"),
            t("container-fluid"),
        }),
        i(0)
    })),
    s("bs_row", {
        t("<div class=\"row\">"),
        i(0),
        t("</div>")
    }),
    s("bs_col", {
        t("<div class=\""),
        c(1, {
            t("col"),
            t("col-"),
            t("col-sm-"),
            t("col-md-"),
            t("col-lg-"),
            t("col-xl-"),
            t("col-xxl-"),
        }),
        t("\">"),
        i(0),
        t("</div>"),
    }),
    s("bs_dropdown", fmt([[
<div class="dropdown">
  <button class="btn btn-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
    {}
  </button>
  <ul class="dropdown-menu">
    <li><a class="dropdown-item" href="#">Action</a></li>
    <li><a class="dropdown-item" href="#">Another action</a></li>
    <li><a class="dropdown-item" href="#">Something else here</a></li>
  </ul>
</div>
    ]], {i(0, "Dropdown Name"), })),
    s("bs_form", fmt([[
 <form>
  <div class="mb-3">
    <label for="exampleInputEmail1" class="form-label">Email address</label>
    <input type="email" class="form-control" id="exampleInputEmail1" aria-describedby="emailHelp">
    <div id="emailHelp" class="form-text">We'll never share your email with anyone else.</div>
  </div>
  <div class="mb-3">
    <label for="exampleInputPassword1" class="form-label">Password</label>
    <input type="password" class="form-control" id="exampleInputPassword1">
  </div>
  <div class="mb-3 form-check">
    <input type="checkbox" class="form-check-input" id="exampleCheck1">
    <label class="form-check-label" for="exampleCheck1">Check me out</label>
  </div>
  {}
  <button type="submit" class="btn btn-primary">Submit</button>
</form>   
    ]], { i(0) })),
    s("bs_form_item", fmt([[
<div class="mb-3">
    <label for="{forid}" class="form-label">{label}</label>
    <input type="{type}" class="form-control" id="{id}">
</div>
{nextline}
    ]], {
       label = i(1, "Label"),
       type = i(2, "text"),
       id = i(3, "id"),
       forid = r(3),
       nextline = i(0)
    })),
    s("bs_card", fmt([[
<div class="card" style="width: 18rem;">
  <img src="..." class="card-img-top" alt="...">
  <div class="card-body">
    <h5 class="card-title">{title}</h5>
    <p class="card-text">{desc}</p>
    <a href="{link}" class="btn btn-primary">{label}</a>
  </div>
</div>
    ]], {
        title = i(1, "Card Title"),
        desc = i(2, "Descriptive text"),
        link = i(3, "#"),
        label = i(0, "Click here"),
    })),
})
