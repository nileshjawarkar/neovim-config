local sys = require("core.util.sys")

local function get_java_path()
    local java_home = os.getenv("JAVA_HOME")
    if java_home ~= nil then
        if sys.is_dir(java_home) then
            return java_home .. "/bin/java", nil
        else
            return nil, "JAVA_HOME path \"" .. java_home .. "\" does not exist."
        end
    end
    return "java", nil
end

local function get_java_version()
    local version = { major = 0, minor = 0, patch = 0 }
    local java_path, err = get_java_path()
    if err ~= nil then
        return version, err
    end
    local r = sys.exec_r(java_path .. " -version 2>&1")
    if r ~= nil then
        for mv, sv, pv in string.gmatch(r, "[version]+%s+.(%d+)%.(%d+)%.(%d+).%s+") do
            local major, minor, patch = tonumber(mv), tonumber(sv), tonumber(pv)
            if major ~= nil and minor ~= nil then
                version.major = major;
                version.minor = minor;
                version.patch = patch;
                break
            end
        end
    else
        err = "Failed to read version using cmd \"" + java_path + " -version\""
    end
    return version, err
end

local get_curbuf_as_pkg = function()
    local str_util = require("core.util.string")
    local parent_path = sys.get_curbuf_dir()
    local pkg, idx = "", -1
    str_util.split(parent_path, sys.get_path_sep(), function(dir_name)
        if dir_name == "src" or dir_name == "Src" or dir_name == "SRC" then
            idx = 0
        elseif idx >= 0 then
            idx = idx + 1
            if idx == 1 and (dir_name == "main" or dir_name == "test") then
            elseif idx == 2 and (dir_name == "java") then
            else
                if pkg ~= "" then
                    pkg = pkg .. "."
                end
                pkg = pkg .. dir_name
            end
        end
    end)
    return pkg
end

local get_curbug_as_class = function()
    local pkg = get_curbuf_as_pkg()
    if pkg ~= nil then
       return pkg .. "." .. sys.get_curbuf_name_without_ext()
    end
end

return {
    get_java_path = get_java_path,
    get_java_version = get_java_version,
    get_curbuf_as_pkg = get_curbuf_as_pkg,
    get_curbuf_as_class = get_curbug_as_class,
}
