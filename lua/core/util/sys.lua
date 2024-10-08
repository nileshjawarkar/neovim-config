local str_util = require("core.util.string")

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
        for key, attr in pairs(value) do
            if type(attr) == "string" then
                print(key .. " -> " .. attr)
            else
                print(key)
                if type(attr) == "table" then
                    dump_table(attr)
                end
            end
        end
    end
end

local function create_dir(dirname)
    if 1 == vim.fn.mkdir(dirname, "p") then
        return true
    end
    return false
end

local function write_to(filename, callback)
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
end

local function dir_has_any(dir, file_list)
    local files = vim.fn.readdir(dir)
    for _, f in ipairs(files) do
        for _, cf in ipairs(file_list) do
            if f == cf then
                return true
            end
        end
    end
    return false
end

local function get_os()
    local os_name = vim.loop.os_uname().sysname
    if os_name == "Linux" or string.find(os_name, "inux") then
        return "Linux"
    elseif os_name == "Windows_NT" or string.find(os_name, "indows") then
        return "Windows"
    end
    return "Other"
end

local function get_path_sep()
    if get_os() == "Windows" then
        return "\\"
    end
    return "/"
end

local function bufname_and_its_parent(withext)
    if withext == nil then withext = true end
    local fullpath = vim.fn.bufname()
    local parent, filename, ext = "", "", ""
    if get_os() == "Windows" then
        parent, filename, ext = string.match(fullpath, "(.-)([^\\]-([^%.]+))$")
    else
        parent, filename, ext = string.match(fullpath, "(.-)([^/]-([^%.]+))$")
    end

    -- if filename didnt have <.extension>, above regex will fail
    if parent == "" or filename == "" then
        local sep = get_path_sep()
        local sub_paths = vim.split(fullpath, sep, { plain = true })
        filename = (sub_paths[#sub_paths] and sub_paths[#sub_paths] or "")
        parent = string.gsub(fullpath, sep .. filename, "")
    else
        if withext == false then
            filename, _ = string.gsub(filename, "%." .. ext, "")
        end
    end
    return filename, parent
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
    write_to = write_to,
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
    create_dir = create_dir,
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
    get_bufname_and_its_parent = bufname_and_its_parent,
    get_curdir_name = function()
        return vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
    end,
    get_os = get_os,
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
    create_project_config = function(ws_dir)
        local conf_dir = ws_dir .. "/.nvim/"
        if is_dir(conf_dir) == false and create_dir(conf_dir) == true then
            write_to(conf_dir .. "config.lua", function(file)
                file.write("-- This is neovim project configuration file")
            end)
        else
            print(".nvim/config.lua - already exist")
        end
    end,
    find_root = function()
        local ws_files = { ".git", "pom.xml", "mvnw", "gradlew", ".nvim" }
        local cur_dir = vim.fn.getcwd()
        if true == dir_has_any(cur_dir, ws_files) then
            return cur_dir;
        else
            return vim.fs.root(0, ws_files)
        end
    end,
    get_curbuf_name = function()
        local filename, _ = bufname_and_its_parent(true)
        return filename
    end,
    get_curbuf_dir = function()
        local _, dir = bufname_and_its_parent(true)
        return dir
    end,
    dir_has_any = dir_has_any,
    create_dirs = function(dir_list)
        if type(dir_list) ~= "table" then
            return false
        end
        local parent = dir_list[0]
        if is_dir(parent) then
            print("Directory already exit - " .. parent)
            return false
        end
        for _, dir in ipairs(dir_list) do
            if not create_dir(dir) then
                print("Failed to create directory - " .. dir)
                return false
            end
        end
        return true
    end,
    get_path_sep = get_path_sep,
    first_time = (function()
        local t = {}
        return function(key)
            if t[key] == nil then
                t[key] = true
                return true
            end
            return false
        end
    end)(),
}
