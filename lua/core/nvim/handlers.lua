local M = {}
local handlers = {}

M.register_close_handler = function(app_or_buf, handler, trigger)
    if handlers.close == nil then
        handlers.close = {}
    end
    if handlers.close[app_or_buf] == nil then
        if trigger ~= nil then
            handlers.close[app_or_buf] = {}
            handlers.close[app_or_buf].handler = handler
            handlers.close[app_or_buf].trigger = trigger
        else
            handlers.close[app_or_buf] = handler
        end
    end
end

M.close = function(required)
    if handlers.close == nil then
        return
    end
    -- Execute in order as give in input
    for _, v in pairs(required) do
        if handlers.close[v] ~= nil then
            local v_handler = handlers.close[v]
            if type(v_handler) == "function" then
                v_handler()
            -- if v_handler is table, it means we have trigger function to check
            -- if trigger function return true then we can execute close handler
            elseif type(v_handler) == "table" then
                if v_handler.trigger ~= nil and v_handler.handler ~= nil then
                    if v_handler.trigger() == true then
                        v_handler.handler()
                    end
                end
            end
        end
    end
end

M.register_close_handler("qf", function()
    if vim.bo.filetype == "qf" then
        vim.cmd('cclose')
    end
end)

return M
