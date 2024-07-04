local home = vim.fn.getenv("JAVA_HOME")
if home == nil then
    print("Please define environment variable \'JAVA_HOME\'");
    return
end

local jdtls = require('config.jdtls')
jdtls.setup()
