
local version, err = require("core.rt.java").get_java_version()
local jtls_err = "Error - Lsp server (jdtls) start failed."
if err ~= nil then
    vim.notify(jtls_err .. " " .. err, vim.log.levels.INFO)
elseif version == nil then
    vim.notify(jtls_err .. " Failed to retrieve java version.", vim.log.levels.INFO)
elseif  version.major < 17 then
    vim.notify("Error : Current java version \"" .. version.major .. "\", minimum required \"17\".", vim.log.levels.INFO)
else
    require('config.jdtls').setup()
end
