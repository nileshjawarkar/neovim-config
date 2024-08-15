local m = {}

local split = function(input_str, sep, cb)
    if type(cb) ~= "function" then return end
    if sep == nil then
        sep = " "
    end
    for str in string.gmatch(input_str, "([^" .. sep .. "]+)") do
        cb(str)
    end
end

m.split = split

return m
