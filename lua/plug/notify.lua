return {
    "rcarriga/nvim-notify",
    config = function()
        local util = require("notify.stages.util")
        local direction = util.DIRECTION.BOTTOM_UP
        local notif_count = 0
        local stage = {
            function(state)
                local next_height = state.message.height + notif_count
                notif_count = notif_count + 1
                local next_row = util.available_slot(state.open_windows, next_height, direction)
                if not next_row then
                    return nil
                end
                return {
                    relative = "editor",
                    anchor = "NE",
                    width = state.message.width,
                    height = state.message.height,
                    col = vim.opt.columns:get(),
                    row = next_row,
                    border = "none",
                }
            end,
            function()
                notif_count = notif_count - 1
                return {
                    col = vim.opt.columns:get(),
                    time = true,
                }
            end,
        }

        local notify = require("notify")
        notify.setup({
            max_height = 3,
            render = "wrapped-compact",
            stages = stage,
            timeout = 1700,
        })
        vim.notify = notify
    end
}
