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

    s("dap_config_java", fmt([[
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

    s("dap_config_c_cpp", fmt([[
    local root_dir = vim.fn.getcwd()
    local function dap_setup()
        local dap = require('dap')
        dap.adapters.gdb = {{
            id = 'gdb',
            type = 'executable',
            command = 'gdb',
            args = {{ '--quiet', '--interpreter=dap' }},
        }}
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

        local function find_executable()
            local path = vim.fn.input({{
                prompt = 'Path to executable: ',
                default = root_dir .. '/',
                completion = 'file',
            }})
            return (path and path ~= '') and path or dap.ABORT
        end

        dap.configurations.c = {{
            {{
                -- This needs explicite use of command => "gdbserver localhost:8901 <program>"
                -- to start the debug session manualy
                name = 'Attach to gdbserver (at 8901)',
                type = 'cppdbg',
                request = 'launch',
                MIMode = 'gdb',
                miDebuggerServerAddress = 'localhost:8901',
                miDebuggerPath = vim.fn.exepath('gdb'),
                cwd = root_dir,
                program = find_executable,
            }}, {{
                name = "Run executable (GDB)",
                type = "gdb", -- 'cppdbg'
                request = "launch",
                program = find_executable,
                cwd = root_dir,
                stopAtEntry = true,
            }}, {{
                name = 'Run executable with arguments (GDB)',
                type = 'gdb',
                request = 'launch',
                program = find_executable,
                args = function()
                    local args_str = vim.fn.input({{
                        prompt = 'Arguments: ',
                    }})
                    return vim.split(args_str, ' +')
                end,
            }}, {{
                name = 'Attach to process (GDB)',
                type = 'gdb',
                request = 'attach',
                processId = require('dap.utils').pick_process,
            }}, {{
                name = 'Run executable (using LLDB)',
                type = 'codelldb',
                request = 'launch',
                program = find_executable,
                cwd = root_dir,
                stopOnEntry = false,
                args = {{}},
                console = 'integratedTerminal',
            }}
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
