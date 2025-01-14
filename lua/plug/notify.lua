return {
    "rcarriga/nvim-notify",
    config = function()
        local notify = require("notify")
        notify.setup({
            max_height = 5,
            render = "wrapped-compact",
            stages = "fade_in_slide_out",
            timeout = 1700,
            top_down = false,
        })
        vim.notify = notify
        vim.keymap.set("n", "<leader>N", notify.dismiss, { desc = "Clear notifications" })
    end
}
