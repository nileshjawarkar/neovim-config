local function get_os()
    local os_name = vim.loop.os_uname().sysname
    if os_name == "Linux" or string.find(os_name, "inux") then
        return "Linux"
    elseif os_name == "Windows_NT" or string.find(os_name, "indows") then
        return "Windows"
    end
    return "Other"
end

local function get_cur_dir()
    return vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
end

return {
    get_os = get_os,
    get_cur_dir = get_cur_dir,
}
