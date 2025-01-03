local m = {
    lsp_config = {},
    dap_setup = nil,
}

local function load_config()
    local ws_path = require("core.util.sys").find_root()
    if ws_path == nil then return end
    local config_path = loadfile(ws_path .. "/.nvim/config.lua")
    if type(config_path) == "function" then
        local config = config_path()
        if config ~= nil and type(config) == "table" then
            if config["lsp_config"] ~= nil and type(config["lsp_config"] == "table") then
                m.lsp_config = config.lsp_config
            end
            if config["dap_setup"] ~= nil and type(config["dap_setup"] == "function") then
                m.dap_setup = config.dap_setup
            end
        end
    end
end

load_config()

return {
    lsp_config = m.lsp_config,
    dap_setup = function()
        if m.dap_setup ~= nil then
            m.dap_setup()
        end
    end,
    reload_config = function()
        load_config()
        if m.dap_setup ~= nil then
            m.dap_setup()
        end
    end
}
