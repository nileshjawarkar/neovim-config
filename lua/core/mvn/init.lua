local pom_util = require("core.mvn.pom")
local util = require("core.mvn.util")

local m = {}
m.find_src_paths = util.find_src_paths
m.createMM_prj = function(self, root_dir, prj_type)
    -- preqs
    local sys = require("core.util.sys")
    if sys.is_file(root_dir .. "/pom.xml") then
        vim.notify("Failed to create project - pom.xml already exit", vim.log.levels.INFO)
        return
    end

    -- Prepare main module
    local root_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
    local pkg = "co.in.nnj.learn"
    local version = "0.0.1"
    local modules = {}
    modules[0] = root_name .. "_lib"
    if prj_type == "JEE" then
        modules[1] = root_name .. "_webapp"
        pkg = pkg .. ".jee"
    end

    -- Prepare and write main pom
    local main_pom = pom_util.build_main_pom(root_name, pkg, version, prj_type, modules)
    local st = sys.write_to(root_dir .. "/pom.xml", function(file)
        file.write(main_pom)
    end)
    if not st then
        vim.notify("Failed to create - " .. root_dir .. "/pom.xml", vim.log.levels.INFO)
        return
    end
    st = sys.write_to(root_dir .. "/.gitignore", function(file)
        file.write(util.get_ignore_content())
    end)
    if not st then
        vim.notify("Failed to create - " .. root_dir .. "/.gitignore", vim.log.levels.INFO)
        return
    end

    -- create PMD rule file
    local pmdRules = require("core/mvn/pmd").get_rules()
    st = sys.write_to(root_dir .. "/pmd-rules.xml", function(file)
        file.write(pmdRules)
    end)
    if not st then
        vim.notify("Failed to create - " .. root_dir .. "/pmd-rules.xml", vim.log.levels.INFO)
        return
    end
    -- create modules
    -- lib module
    local mod_deps = nil
    if false == self:createLib_module(root_dir, prj_type, modules[0], pkg, version, root_name, pkg, version, mod_deps) then
        vim.notify("Failed to create module - " .. modules[0], vim.log.levels.INFO)
        return
    end
    vim.notify("Created maven module - " .. modules[0], vim.log.levels.INFO)
    if prj_type == "JEE" then
        mod_deps = {}
        mod_deps[0] = {
            name = modules[0],
            pkg = pkg,
            version = version,
            scope = ""
        }

        if false == self:createWar_module(root_dir, prj_type, modules[1], pkg, version, root_name, pkg, version, mod_deps) then
            vim.notify("Failed to create module - " .. modules[1], vim.log.levels.INFO)
        end
        vim.notify("Created maven module - " .. modules[1], vim.log.levels.INFO)
    end
    vim.notify("Created maven project - " .. root_name, vim.log.levels.INFO)
end

m.createLib_module = function(self, root_dir, prj_type, name, pkg, version, parent_name, parent_pkg, parent_version, deps)
    local mod_path = root_dir .. "/" .. name
    local sys = require("core.util.sys")
    if sys.is_dir(mod_path) then
        vim.notify("Failed to create module - " .. name .. " already exit", vim.log.levels.INFO)
        return false
    end
    local dirs_needed = {}
    dirs_needed[0] = mod_path
    dirs_needed[1] = mod_path .. "/src"
    dirs_needed[2] = mod_path .. "/src/main"
    dirs_needed[3] = mod_path .. "/src/test"
    dirs_needed[4] = mod_path .. "/src/main/java"
    dirs_needed[5] = mod_path .. "/src/main/resources"
    dirs_needed[6] = mod_path .. "/src/test/java"
    dirs_needed[7] = mod_path .. "/src/test/resources"
    if sys.create_dirs(dirs_needed) then
        local module_pom = pom_util.build_module_pom(prj_type, "jar", name, pkg, version, parent_name, parent_pkg,
            parent_version, deps)
        local st = sys.write_to(mod_path .. "/pom.xml", function(file)
            file.write(module_pom)
        end)
        if not st then
            vim.notify("Failed to create - " .. mod_path .. "/pom.xml", vim.log.levels.INFO)
            return false
        end
        return true
    end
    return false
end

m.createWar_module = function(self, root_dir, prj_type, name, pkg, version, parent_name, parent_pkg, parent_version, deps)
    local root_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
    local mod_path = root_dir .. "/" .. name
    local sys = require("core.util.sys")
    if sys.is_dir(mod_path) then
        vim.notify("Failed to create module - " .. name .. " already exit", vim.log.levels.INFO)
        return false
    end

    local dirs_needed = {}
    dirs_needed[0] = mod_path
    dirs_needed[1] = mod_path .. "/src"
    dirs_needed[2] = mod_path .. "/src/main"
    dirs_needed[3] = mod_path .. "/src/main/resources"
    dirs_needed[4] = mod_path .. "/src/main/resources/META-INF"
    dirs_needed[5] = mod_path .. "/src/main/webapp"
    dirs_needed[6] = mod_path .. "/src/main/webapp/WEB-INF"
    if sys.create_dirs(dirs_needed) then
        local module_pom = pom_util.build_module_pom(prj_type, "war", name, pkg, version, parent_name, parent_pkg,
            parent_version, deps)
        local st = sys.write_to(mod_path .. "/pom.xml", function(file)
            file.write(module_pom)
        end)
        if not st then
            vim.notify("Failed to create - " .. mod_path .. "/pom.xml", vim.log.levels.INFO)
            return false
        end

        st = sys.write_to(mod_path .. "/src/main/webapp/WEB-INF/web.xml", function(file)
            file.write(util.get_web_xml(root_name))
        end)
        if not st then
            vim.notify("Failed to create - " .. mod_path .. "/src/main/webapp/WEB-INF/web.xml", vim.log.levels.INFO)
            return false
        end

        st = sys.write_to(mod_path .. "/src/main/webapp/WEB-INF/beans.xml", function(file)
            file.write(util.get_beans_xml())
        end)
        if not st then
            vim.notify("Failed to create - " .. mod_path .. "/src/main/webapp/WEB-INF/beans.xml", vim.log.levels.INFO)
            return false
        end

        st = sys.write_to(mod_path .. "/src/main/webapp/WEB-INF/resources.xml", function(file)
            file.write(util.get_tomee_resource_xml())
        end)
        if not st then
            vim.notify("Failed to create - " .. mod_path .. "/src/main/webapp/WEB-INF/resources.xml", vim.log.levels.INFO)
            return false
        end

        st = sys.write_to(mod_path .. "/src/main/resources/application.properties", function(file)
            file.write(util.get_application_props())
        end)
        if not st then
            vim.notify("Failed to create - " .. mod_path .. "/src/main/resources/application.properties", vim.log.levels.INFO)
            return false
        end
        st = sys.write_to(mod_path .. "/src/main/resources/META-INF/persistence.xml", function(file)
            file.write(util.get_persistence_xml())
        end)
        if not st then
            vim.notify("Failed to create - " .. mod_path .. "/src/main/resources/META-INF/persistence.xml", vim.log.levels.INFO)
            return false
        end
        return true
    end
    return false
end

return m
