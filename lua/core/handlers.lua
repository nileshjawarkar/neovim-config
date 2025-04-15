local M = {}
local handlers = {}

M.register_close_handler = function(app_or_buf, handler)
    if handlers.close == nil then
        handlers.close = {}
    end
    if handlers.close[app_or_buf] == nil then
        handlers.close[app_or_buf] = handler
    end
end

local function exec_handlers(required, any_one)
    if handlers.close == nil or required == nil or any_one == nil then
        return 0
    end
    local exec_count = 0
    -- Execute in order as give in input
    for _, v in pairs(required) do
        if handlers.close[v] ~= nil then
            local v_handler = handlers.close[v]
            -- if v_handler is function, then checks for probable execution
            -- will be done inside that function only.
            if type(v_handler) == "function" then
                if true == v_handler() then
                    if any_one then return 1 end
                    exec_count = exec_count + 1
                end
            end
        end
    end
    return exec_count
end

M.closeAny = function(required)
    return exec_handlers(required, true)
end

M.close = function(required)
    return exec_handlers(required, false)
end

M.register_close_handler("qf", function()
    if vim.bo.filetype == "qf" then
        vim.cmd('cclose')
        return true
    end
    return false
end)

return M
