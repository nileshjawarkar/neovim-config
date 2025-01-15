return {
    "rcarriga/nvim-notify",
    config = function()
        local notify = require("notify")
        notify.setup({
            max_height = 5,
            render = "compact",
            stages = "fade_in_slide_out",
            timeout = 1700,
        })
        vim.notify = notify
        vim.keymap.set("n", "<leader>N", notify.dismiss, { desc = "Clear notifications" })
    end
}
