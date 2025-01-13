return {
    "rcarriga/nvim-notify",
    config = function()
        local notify = require("notify")
        notify.setup({
            max_height = 3,
            top_down = false,
            render = "wrapped-compact",
        })
        vim.notify = notify
    end
}
