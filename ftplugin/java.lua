local jdtls = require('config.jdtls')
local version, err = jdtls.get_java_version()
local jtls_err = "Error - Lsp server (jdtls) start failed."
if err ~= nil then
    print(jtls_err .. " " .. err)
elseif version == nil then
    print(jtls_err .. " Failed to retrieve java version.")
elseif  version.major < 17 then
    print("Error : Current java version \"" .. version.major .. "\", minimum required \"17\".")
else
    print("Starting language server ...")
    jdtls.setup()
end
