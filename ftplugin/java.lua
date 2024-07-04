local jdtls = require('config.jdtls')
local version = jdtls.get_java_version().major
if  version >= 17 then
    jdtls.setup()
else
    print("Error : Current java version \"" .. version .. "\", minimum required \"17\".")
end
