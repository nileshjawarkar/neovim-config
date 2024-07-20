local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require('luasnip.extras.fmt').fmt

ls.add_snippets("lua", {
    s("lfun", {
        t("local function "),
        i(1, "name"),
        t("("),
        i(2, ""),
        t({ ")", "\t" }),
        i(0),
        t({ "", "end" }),
    }),

    s("fun", {
        t("function("),
        i(1, ""),
        t({ ")", "\t" }),
        i(2),
        t({ "", "end" }),
        i(0),
    }),

    s("lrequire", {
        t("local "),
        f(function(import_name)
            local parts = vim.split(import_name[1][1], ".", { plain = true })
            return (parts[#parts] and string.gsub(parts[#parts], "%-", "_")) or ""
        end, { 1 }),
        t(" = require(\""),
        i(1, "import.name"),
        t("\")"),
        i(0)
    }),

    s("config_java", fmt([[
    local dap = require('dap')
    dap.configurations.java = {{
      {{
        type = 'java';
        request = 'attach';
        name = "Debug (Attach) - Remote";
        hostName = "127.0.0.1";
        port = 8000;
      }},
      {{
        type = "java",
        -- classPaths = "",
        -- modulePaths = "",
        -- javaExec = "/path/to/your/bin/java",
        projectName = "Valid Project Name",
        mainClass = "your.package.name.MainClassName",
        name = "Launch MainClassName",
        request = "launch",
      }}
    }}
    ]], {})),

    s("config_c_cpp", fmt([[
    local root_dir = vim.fn.getcwd()
    local function dap_setup()
        local dap = require('dap')
        dap.adapters.cppdbg = {{
            id = 'cppdbg',
            type = 'executable',
            command = vim.fn.exepath("OpenDebugAD7"),
        }}
        dap.adapters.codelldb = {{
            type = 'server',
            port = '8901',
            executable = {{
                command = vim.fn.exepath('codelldb'),
                args = {{ '--port', '8901' }},
            }},
        }}
        dap.configurations.c = {{
            {{
                -- This needs explicite use of command => "gdbserver localhost:8901 <program>"
                -- to start the debug session manualy
                name = 'Attach (to gdbserver at :8901)',
                type = 'cppdbg',
                request = 'launch',
                MIMode = 'gdb',
                miDebuggerServerAddress = 'localhost:8901',
                miDebuggerPath = vim.fn.exepath('gdb'),
                cwd = root_dir,
                program = function()
                    return vim.fn.input('Path to executable: ', root_dir .. '/', 'file')
                end,
            }}, {{
                name = "Launch (using GDB)",
                type = "cppdbg",
                request = "launch",
                program = function()
                    return vim.fn.input('Path to executable: ', root_dir .. '/', 'file')
                end,
                cwd = root_dir,
                stopAtEntry = true,
            }}, {{
                name = 'Launch (using LLDB)',
                type = 'codelldb',
                request = 'launch',
                program = function()
                    return vim.fn.input('Path to executable: ', root_dir .. '/', 'file')
                end,
                cwd = root_dir,
                stopOnEntry = false,
                args = {{}},
                console = 'integratedTerminal',
            }}, 
        }}
        dap.configurations.cpp = dap.configurations.c
    end

    --+ Way to configure clangd compiler inputs
    --+-----------------------------------------
    --+ If:
    --+   PathMatch: .*\.cpp

    --+ CompileFlags:
    --+   Add: [-std=c++20]

    --+ ---
    --+ If:
    --+   PathMatch: .*\.c

    --+ CompileFlags:
    --+   Compiler: zig cc
    --+   Add: [-Wall, -isysroot=/home/nilesh/.local/zig ]
    --+-------------------------------------------

    return {{
        dap_setup = dap_setup,
        lsp_config = {{
            clangd = {{
                "clangd", "--enable-config",
                -- "/home/nilesh/.local/llvm-180108/bin/clangd", "--enable-config",
                -- "--compile-commands-dir=" .. root_dir,
                -- "--query-driver=/home/nilesh/.local/zig/zig_cc.sh",
            }},
        }},
    }}
    ]], {})),
})
