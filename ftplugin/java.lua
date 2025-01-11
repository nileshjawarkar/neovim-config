local jdtls_config = require('config.jdtls')
local jdtls_util = require('config.jdtls.util')

local version, err = jdtls_util.get_java_version()
local jtls_err = "Error - Lsp server (jdtls) start failed."
if err ~= nil then
    print(jtls_err .. " " .. err)
elseif version == nil then
    print(jtls_err .. " Failed to retrieve java version.")
elseif  version.major < 17 then
    print("Error : Current java version \"" .. version.major .. "\", minimum required \"17\".")
else
    jdtls_config.setup()
end
