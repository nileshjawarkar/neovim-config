local function table_dump(value)
    if type(value) == "table" then
        for key, attr in pairs(value) do
            if type(attr) == "string" then
                print(key .. " -> " .. attr)
            else
                print(key)
                if type(attr) == "table" then
                    table_dump(attr)
                end
            end
        end
    end
end

local function table_len(value)
    local len = 0
    if type(value) == "table" then
        for _ in pairs(value) do
            len = len + 1
        end
    end
    return len
end

return {
    dump = table_dump,
    len = table_len,
}
