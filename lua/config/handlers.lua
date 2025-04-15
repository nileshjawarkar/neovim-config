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
        end
        require("config.dap").close()
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
    end
end

return M
