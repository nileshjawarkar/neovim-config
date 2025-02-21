return {
    'lewis6991/gitsigns.nvim',
    config = function()
        local gs = require('gitsigns')
        vim.keymap.set({ "n", "v" }, "<leader>hn", function()
            gs.nav_hunk('next')
        end, { noremap = true, silent = true, desc = "Prev. hunk", })
        vim.keymap.set({ "n", "v" }, "<leader>hp", function()
            gs.nav_hunk('prev')
        end, { noremap = true, silent = true, desc = "Prev. hunk", })
        vim.keymap.set({ "n", "v" }, "<leader>hs", gs.stage_hunk,
            { noremap = true, silent = true, desc = "Stage hunk", })
        vim.keymap.set({ "n", "v" }, "<leader>hP", gs.preview_hunk_inline,
            { noremap = true, silent = true, desc = "Preview hunk", })
        vim.keymap.set('n', '<leader>hd', gs.diffthis, { noremap = true, silent = true, desc = "Diff this", })
        vim.keymap.set('n', '<leader>hq', function() gs.setqflist('all') end,
            { noremap = true, silent = true, desc = "List modifications", })

        gs.setup()
    end,
}
