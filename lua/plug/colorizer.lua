return {
    "norcalli/nvim-colorizer.lua",
    config = function()
        local opts = {
            RGB      = true, -- #RGB hex codes
            RRGGBB   = true, -- #RRGGBB hex codes
            names    = true, -- "Name" codes like Blue
            RRGGBBAA = true, -- #RRGGBBAA hex codes
            rgb_fn   = true, -- CSS rgb() and rgba() functions
            hsl_fn   = true, -- CSS hsl() and hsla() functions
            css      = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
            css_fn   = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
        }

        require 'colorizer'.setup {
            scss = opts,
            css = opts,
            javascript = opts,
            html = {
                mode = 'foreground',
            }
        }
    end
}
