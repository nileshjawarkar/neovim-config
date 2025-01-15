return {
    "rcarriga/nvim-notify",
    config = function()
        local notify = require("notify")
        local stages_util = require("notify.stages.util")

        local function slide_out(direction)
            return {
                function(state)
                    local next_height = state.message.height + 1
                    local next_row = stages_util.available_slot(state.open_windows, next_height, direction)
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
                        style = "minimal",
                    }
                end,
                function(state, win)
                    return {
                        col = vim.opt.columns:get(),
                        time = true,
                        row = stages_util.slot_after_previous(win, state.open_windows, direction),
                    }
                end,
                function(state, win)
                    return {
                        width = {
                            1,
                            frequency = 2.5,
                            damping = 0.9,
                            complete = function(cur_width)
                                return cur_width < 3
                            end,
                        },
                        col = { vim.opt.columns:get() },
                        row = {
                            stages_util.slot_after_previous(win, state.open_windows, direction),
                            frequency = 3,
                            complete = function()
                                return true
                            end,
                        },
                    }
                end,
            }
        end

        notify.setup({
            max_height = 5,
            render = "wrapped-compact",
            -- stages = "fade_in_slide_out",
            stages = slide_out(stages_util.DIRECTION.BOTTOM_UP),
            timeout = 1700,
        })
        vim.notify = notify
        vim.keymap.set("n", "<leader>N", notify.dismiss, { desc = "Clear notifications" })
    end
}
