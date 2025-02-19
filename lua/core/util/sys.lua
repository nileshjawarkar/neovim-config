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

local function get_cwd()
   return vim.fs.normalize(vim.fn.getcwd())
end

local function dir_has_any_file_or_file_with_ext(dir, filename_list, fileext_list)
    local files = vim.fn.readdir(dir)
    for _, curfile in ipairs(files) do
        for _, fname in ipairs(filename_list) do
            if curfile == fname then
                return true
            end
        end
        if fileext_list ~= nil then
            local curext = string.match(curfile, "^.*%.(.+)$")
            if curext ~= nil and curext ~= "" then
                for _, ext in ipairs(fileext_list) do
                    if ext == curext then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function dir_has_any(dir, filename_list)
    return dir_has_any_file_or_file_with_ext(dir, filename_list, nil)
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

local sep = "/"
local get_path_sep = function()
    return sep
end

local function rm_ext_from_filename(filename)
    local ext = string.match(filename, "^.*(%..+)$")
    if ext ~= nil then
        filename = filename:gsub(ext, "")
    end
    return filename;
end

local function split_filepath(filepath, withext)
    if filepath == nil then return nil, nil end
    if withext == nil then withext = true end
    local filename = vim.fs.basename(filepath)
    local parent = vim.fs.dirname(filepath)
    if withext == false then
        filename = rm_ext_from_filename(filename)
    end
    return filename, parent
end

local function bufname_and_its_parent(withext)
    local fullpath = vim.fn.bufname()
    return split_filepath(fullpath, withext)
end

local M = {}
M.read_from = function(filename, callback)
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
end

M.write_to = write_to

M.append_to = function(filename, callback)
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
end

M.create_dir = create_dir

M.rm_rf = function(dirname)
    if 0 == vim.fn.delete(dirname, "rf") then
        return true
    end
    return false
end

M.is_dir = is_dir

M.read_dir = function(dirname)
    if is_dir(dirname) then
        local file_list = {}
        for _, ft_path in ipairs(vim.split(vim.fn.glob(dirname .. "/*"), '\n', { trimempty = true })) do
            table.insert(file_list, ft_path)
        end
        return true, file_list
    end
    return false, nil
end

M.is_file = function(filepath)
    if is_dir(filepath) == true then return false end
    local file = open_file(filepath, "r")
    if file ~= nil then
        file.close()
        return true
    end
    return false
end

M.get_cwd = get_cwd

M.get_curbuf_name_without_ext = function()
    local filename = vim.fs.basename(vim.fn.bufname())
    return rm_ext_from_filename(filename)
end

M.get_curbuf_name = function()
    return vim.fs.basename(vim.fn.bufname())
end

M.get_curbuf_dir = function()
    return vim.fs.dirname(vim.fn.bufname())
end

M.get_bufname_and_its_parent = bufname_and_its_parent

M.get_curdir_name = function()
    return vim.fs.basename(vim.fn.getcwd())
end

M.get_os = get_os

M.exec_r = function(command)
    local h = io.popen(command, "r")
    if h == nil then
        return nil
    end
    local r = h:read("*a")
    h:close()
    return r
end

M.create_project_config = function(ws_dir)
    local conf_dir = ws_dir .. "/.nvim/"
    if is_dir(conf_dir) == false and create_dir(conf_dir) == true then
        write_to(conf_dir .. "config.lua", function(file)
            file.write("-- This is neovim project configuration file")
        end)
    else
        vim.notify(".nvim/config.lua - already exist", vim.log.levels.INFO)
    end
end

M.find_root = function()
    local root = nil
    local prj_markers = { "pom.xml", "mvnw", "gradlew", ".git", ".nvim", }
    local prj_ext_marker = { "sln", "csproj" }
    -- Step 1: In current directory file project-tool related files,
    -- if found any of them return cur-dir as root-dir
    local cwd = get_cwd()
    if true == dir_has_any_file_or_file_with_ext(cwd, prj_markers, prj_ext_marker) then
        return cwd
    end
    -- Step 2: Get bufname, if not empty/nil
    local bufpath = vim.fn.bufname()
    if bufpath ~= nil and bufpath ~= "" then
        local ext = string.match(bufpath, "^.*(%..+)$")
        if ext == ".cs" then
            root = vim.fs.root(0, function(name, _)
                return string.match(name, "%.csproj$") or string.match(name, "%.sln$")
            end)
            if root ~= nil then
                return root
            end
        end
        return vim.fs.root(0, prj_markers)
    end
    return nil
end

M.dir_has_any = dir_has_any

M.create_dirs = function(dir_list)
    if type(dir_list) ~= "table" then
        return false
    end
    local parent = dir_list[0]
    if is_dir(parent) then
        vim.notify("Directory already exit - " .. parent, vim.log.levels.INFO)
        return false
    end
    for _, dir in ipairs(dir_list) do
        if not create_dir(dir) then
            vim.notify("Failed to create directory - " .. dir, vim.log.levels.INFO)
            return false
        end
    end
    return true
end

M.get_path_sep = get_path_sep

M.path_builder = function(value)
    local path = value
    return {
        append = function(self, value1)
            if path == nil then
                path = value1
            else
                path = path .. sep .. value1
            end
            return self
        end,
        build = function(_)
            return path
        end
    }
end

M.first_time = (function()
    local accessed = {}
    return {
        check = function(key)
            if accessed[key] == nil then
                return true
            end
            return false
        end,
        setFalse = function(key)
            accessed[key] = true
        end
    }
end)()

return M
