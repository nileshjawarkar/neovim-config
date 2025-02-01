return {
    "norcalli/nvim-colorizer.lua",
    config = function()
        local opts = {
            RGB      = true, RRGGBB   = true,
            names    = true, RRGGBBAA = true,
            rgb_fn   = true, hsl_fn   = true,
            css      = true, css_fn   = true,
        }
        require 'colorizer'.setup {
            scss = opts, css = opts,
            javascript = opts,
            yaml = opts, svg = opts,
            html = { mode = 'foreground', }
        }
    end
}
