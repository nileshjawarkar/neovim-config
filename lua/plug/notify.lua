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
        vim.notify = function(msg, level, opt)
            local buftype = vim.bo.filetype
            if buftype ~= "NeogitStatus" then
                notify(msg, level, opt)
            end
        end
    end
}
