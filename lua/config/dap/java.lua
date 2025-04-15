local dap = require('dap')
local javart = require("core.rt.java")

dap.configurations.java = {}
local function add_config(config)
    table.insert(dap.configurations.java, config)
end

local function get_port()
    local port = vim.fn.input({
        prompt = 'Port number: ',
        default = '8000',
    })
    return (port and port ~= '') and tonumber(port) or dap.ABORT
end

local function setDefaults()
    add_config({
        type = "java",
        mainClass = javart.get_curbuf_as_class,
        name = "Launch current class",
        request = "launch",
    })
    add_config({
        type = 'java',
        request = 'attach',
        name = "Attach to debug port",
        hostName = "127.0.0.1",
        port = get_port,
    })
end

return {
    set_defaults = setDefaults,
    add = add_config,
}
