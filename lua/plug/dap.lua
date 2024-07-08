return {
    "rcarriga/nvim-dap-ui",
    dependencies = {
        -- ui plugins to make debugging simplier
        "mfussenegger/nvim-dap",
        "nvim-neotest/nvim-nio",
        "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
        require("config.dap").setup()
    end,
}
