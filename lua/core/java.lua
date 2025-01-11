local function get_java_path()
    local java_home = os.getenv("JAVA_HOME")
    if java_home ~= nil then
        local sys = require("core.util.sys")
        if sys.is_dir(java_home) then
            return java_home .. "/bin/java", nil
        else
            return nil, "JAVA_HOME path \"" .. java_home .. "\" does not exist."
        end
    end
    return "java", nil
end

local function get_java_version()
    local sys = require("core.util.sys")
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

return {
    get_java_path = get_java_path,
    get_java_version = get_java_version,
}

