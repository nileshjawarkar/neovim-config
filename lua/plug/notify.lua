return {
    "rcarriga/nvim-notify",
    config = function()
        local notify = require("notify")
        notify.setup({
            max_height = 3,
            top_down = false,
            render = "compact",
            stages = "fade",
            timeout = 1200,
        })
        vim.notify = notify
    end
}
