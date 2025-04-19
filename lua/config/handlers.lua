local M = {}
M.closeThemForMe = function(forMe)
    if forMe == "dap" then
        if vim.bo.filetype == "qf" then
            vim.cmd('cclose')
        elseif vim.bo.filetype == "NvimTree" then
            require("nvim-tree.api").tree.close()
        elseif vim.bo.filetype == "term" then
            require("core.term").hideTerm()
        end
    elseif forMe == "git" then
        if vim.bo.filetype == "qf" then
            vim.cmd('cclose')
        elseif vim.bo.filetype == "NvimTree" then
            require("nvim-tree.api").tree.close()
        elseif vim.bo.filetype == "term" then
            require("core.term").hideTerm()
        else
            require("config.dap").close()
        end
    elseif forMe == "telescope" then
        if vim.bo.filetype == "qf" then
            vim.cmd('cclose')
        elseif vim.bo.filetype == "term" then
            require("core.term").hideTerm()
        end
    elseif forMe == "tree" then
        if vim.bo.filetype == "NeogitStatus" then
            vim.cmd("bdelete")
        end
        require("config.dap").close()
    elseif forMe == "term" then
        if vim.bo.filetype == "NeogitStatus" then
            vim.cmd("bdelete")
        end
        require("config.dap").close()
    elseif forMe == "qf" then
        if vim.bo.filetype == "NvimTree" then
            require("nvim-tree.api").tree.close()
        end
        require("config.dap").close()
    elseif forMe == "any" then
        local windows = vim.api.nvim_tabpage_list_wins(0)
        if #windows > 1 then
            local isAny = false
            if vim.bo.filetype == "qf" then
                vim.cmd('cclose')
                isAny = true
            elseif vim.bo.filetype == "NvimTree" then
                require("nvim-tree.api").tree.close()
                isAny = true
            elseif vim.bo.filetype == "term" then
                require("core.term").hideTerm()
                isAny = true
            else
                isAny = require("config.dap").close()
            end
            if not isAny then
                vim.api.nvim_command('q')
            end
        else
            vim.api.nvim_command('bd')
        end
    end
end

return M
