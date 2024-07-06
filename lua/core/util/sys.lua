local function open_file(filename, mode)
    local file = io.open(filename, mode)
    if file == nil then
        return nil
    end
    return {
        close = function()
            file:close()
        end,
        read_all = function()
            return file:read("*a")
        end,
        read_line = function()
            return file:read()
        end,
        write = function(data)
            file:write(data)
        end,
        flush = function()
            file:flush()
        end,
        seek_start = function()
            file:seek("set", 0)
        end,
        seek_end = function()
            file:seek("end", 0)
        end,
        seek_from_cur = function(offset)
            file:seek("cur", offset)
        end,
    }
end


local is_dir = function(dirname)
    if 1 == vim.fn.isdirectory(dirname) then
        return true
    end
    return false
end

local function dump_table(value)
    if type(value) == "table" then
        for key, attr in ipairs(value) do
            print(key .. " -> " .. attr)
        end
    end
end

return {
    read_from = function(filename, callback)
        local file = open_file(filename, "r")
        if file ~= nil and callback ~= nil then
            local rfile = {
                seek_start = file.seek_start,
                seek_end = file.seek_end,
                seek_from_cur = file.seek_from_cur,
                read_all = file.read_all,
                read_line = file.read_line,
            }
            callback(rfile)
            file.close()
            return true
        end
        return false
    end,
    write_to = function(filename, callback)
        local file = open_file(filename, "w+")
        if file ~= nil and callback ~= nil then
            local wfile = {
                seek_start = file.seek_start,
                seek_end = file.seek_end,
                seek_from_cur = file.seek_from_cur,
                write = file.write,
                flush = file.flush,
            }
            callback(wfile)
            file.close()
            return true
        end
        return false
    end,
    append_to = function(filename, callback)
        local file = open_file(filename, "a+")
        if file ~= nil and callback ~= nil then
            local afile = {
                write = file.write,
                flush = file.flush,
            }
            callback(afile)
            file.close()
            return true
        end
        return false
    end,
    create_dir = function(dirname)
        if 1 == vim.fn.mkdir(dirname, "p") then
            return true
        end
        return false
    end,
    rm_rf = function(dirname)
        if 0 == vim.fn.delete(dirname, "rf") then
            return true
        end
        return false
    end,
    is_dir = is_dir,
    read_dir = function(dirname)
        if is_dir(dirname) then
            local file_list = {}
            for _, ft_path in ipairs(vim.split(vim.fn.glob(dirname .. "/*"), '\n', { trimempty = true })) do
                table.insert(file_list, ft_path)
            end
            return true, file_list
        end
        return false, nil
    end,
    is_file = function(filepath)
        if is_dir(filepath) == true then return false end
        local file = open_file(filepath, "r")
        if file ~= nil then
            file.close()
            return true
        end
        return false
    end,
    get_curdir_name = function()
        return vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
    end,
    get_os = function()
        local os_name = vim.loop.os_uname().sysname
        if os_name == "Linux" or string.find(os_name, "inux") then
            return "Linux"
        elseif os_name == "Windows_NT" or string.find(os_name, "indows") then
            return "Windows"
        end
        return "Other"
    end,
    exec_r = function(command)
        local h = io.popen(command, "r")
        if h == nil then
            return nil
        end
        local r = h:read("*a")
        h:close()
        return r
    end,
    dump_table = dump_table,
}
