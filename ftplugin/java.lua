local jdtls = require('jdtls')
local data_path = vim.fn.stdpath("data")
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = data_path .. '/jdtls-workspace/' .. project_name

local home = vim.fn.getenv("JAVA_HOME")
if home == nil then
    print("Please define JAVA_HOME");
    return
end

-- decide config dir as per OS
local os_name = vim.loop.os_uname().sysname
local jdtls_config = "config_mac"
if os_name == "Linux" or string.find(os_name, "inux") then
    jdtls_config = "config_linux"
elseif os_name == "Windows_NT" or string.find(os_name, "indows") then
    jdtls_config = "config_win"
end

local config = {
  cmd = {
    'java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-javaagent:' ..  data_path .. '/mason/share/jdtls/lombok.jar',
    '-Xmx4g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    '-jar', data_path .. '/mason/share/jdtls/plugins/org.eclipse.equinox.launcher.jar',
    '-configuration', data_path .. '/mason/packages/jdtls/' .. jdtls_config,
    '-data', workspace_dir
  },

  root_dir = require('jdtls.setup').find_root({'.git', 'mvnw', 'pom.xml', 'build.gradle'}),
  settings = {
    java = {
        home = vim.fn.getenv("JAVA_HOME"),
    },
    completion = {
      favoriteStaticMembers = {
        "org.hamcrest.MatcherAssert.assertThat",
        "org.hamcrest.Matchers.*",
        "org.hamcrest.CoreMatchers.*",
        "org.junit.jupiter.api.Assertions.*",
        "java.util.Objects.requireNonNull",
        "java.util.Objects.requireNonNullElse",
        "org.mockito.Mockito.*",
      },
      importOrder = {
        "java",
        "javax",
        "jakarta",
        "com",
        "org"
      },
    },
    extendedClientCapabilities = jdtls.extendedClientCapabilities,
    sources = {
      organizeImports = {
        starThreshold = 9999,
        staticStarThreshold = 9999,
      },
    },
    codeGeneration = {
      toString = {
        template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
      },
      useBlocks = true,
    },
  },
  -- Needed for auto-completion with method signatures and placeholders
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
  flags = {
    allow_incremental_sync = true,
  },
}

-- Filetype-specific keymaps (these can be done in the ftplugin directory instead if you prefer)
local keymap = vim.keymap
keymap.set("n", "<leader>gO", function()
    jdtls.organize_imports()
end, { desc = "Organize imports" })
keymap.set("n", "gO", function()
    jdtls.organize_imports()
end, { desc = "Organize imports" })

keymap.set("n", "<leader>gu", function()
    jdtls.update_projects_config()
end, { desc = "Update project config" })

-- This starts a new client & server, or attaches to an existing client & server based on the `root_dir`.
jdtls.start_or_attach(config)
