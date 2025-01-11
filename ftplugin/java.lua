
local version, err = require("core.java").get_java_version()
local jtls_err = "Error - Lsp server (jdtls) start failed."
if err ~= nil then
    print(jtls_err .. " " .. err)
elseif version == nil then
    print(jtls_err .. " Failed to retrieve java version.")
elseif  version.major < 17 then
    print("Error : Current java version \"" .. version.major .. "\", minimum required \"17\".")
else
    require('config.jdtls').setup()
end
