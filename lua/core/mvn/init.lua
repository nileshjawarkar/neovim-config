
local pom_util = require("core.mvn.pom")
local util = require("core.mvn.util")
local sys = require("core.util.sys")

local function notify(msg)
    vim.notify(msg, vim.log.levels.INFO)
end

local m = {}
m.find_src_paths = util.find_src_paths

m.createMM_prj = function(self, root_dir, prj_type)
    if sys.is_file(root_dir .. "/pom.xml") then
        notify("Failed to create project - pom.xml already exists")
        return
    end

    local root_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
    local pkg = "co.in.nnj.learn"
    local version = "0.0.1"
    local modules = {}
    table.insert(modules, root_name .. "_lib")
    if prj_type == "JEE" then
        table.insert(modules, root_name .. "_webapp")
        pkg = pkg .. ".jee"
    end

    local main_pom = pom_util.build_main_pom(root_name, pkg, version, prj_type, modules)
    if not sys.write_to(root_dir .. "/pom.xml", function(file) file.write(main_pom) end) then
        notify("Failed to create - " .. root_dir .. "/pom.xml")
        return
    end
    if not sys.write_to(root_dir .. "/.gitignore", function(file) file.write(util.get_ignore_content()) end) then
        notify("Failed to create - " .. root_dir .. "/.gitignore")
        return
    end

    local pmdRules = require("core/mvn/pmd").get_rules()
    if not sys.write_to(root_dir .. "/pmd-rules.xml", function(file) file.write(pmdRules) end) then
        notify("Failed to create - " .. root_dir .. "/pmd-rules.xml")
        return
    end

    local mod_deps = nil
    if not self:createLib_module(root_dir, prj_type, modules[1], pkg, version, root_name, pkg, version, mod_deps) then
        notify("Failed to create module - " .. modules[1])
        return
    end
    notify("Created maven module - " .. modules[1])

    if prj_type == "JEE" then
        mod_deps = {
            {
                name = modules[1],
                pkg = pkg,
                version = version,
                scope = ""
            }
        }
        if not self:createWar_module(root_dir, prj_type, modules[2], pkg, version, root_name, pkg, version, mod_deps) then
            notify("Failed to create module - " .. modules[2])
        end
        notify("Created maven module - " .. modules[2])
    end
    notify("Created maven project - " .. root_name)
end

m.createLib_module = function(self, root_dir, prj_type, name, pkg, version, parent_name, parent_pkg, parent_version, deps)
    local mod_path = root_dir .. "/" .. name
    if sys.is_dir(mod_path) then
        notify("Failed to create module - " .. name .. " already exists")
        return false
    end
    local dirs_needed = {
        mod_path,
        mod_path .. "/src",
        mod_path .. "/src/main",
        mod_path .. "/src/test",
        mod_path .. "/src/main/java",
        mod_path .. "/src/main/resources",
        mod_path .. "/src/test/java",
        mod_path .. "/src/test/resources"
    }
    if sys.create_dirs(dirs_needed) then
        local module_pom = pom_util.build_module_pom(prj_type, "jar", name, pkg, version, parent_name, parent_pkg, parent_version, deps)
        if not sys.write_to(mod_path .. "/pom.xml", function(file) file.write(module_pom) end) then
            notify("Failed to create - " .. mod_path .. "/pom.xml")
            return false
        end
        return true
    end
    return false
end

m.createWar_module = function(self, root_dir, prj_type, name, pkg, version, parent_name, parent_pkg, parent_version, deps)
    local root_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
    local mod_path = root_dir .. "/" .. name
    if sys.is_dir(mod_path) then
        notify("Failed to create module - " .. name .. " already exists")
        return false
    end
    local dirs_needed = {
        mod_path,
        mod_path .. "/src",
        mod_path .. "/src/main",
        mod_path .. "/src/main/resources",
        mod_path .. "/src/main/resources/META-INF",
        mod_path .. "/src/main/webapp",
        mod_path .. "/src/main/webapp/WEB-INF"
    }
    if sys.create_dirs(dirs_needed) then
        local module_pom = pom_util.build_module_pom(prj_type, "war", name, pkg, version, parent_name, parent_pkg, parent_version, deps)
        if not sys.write_to(mod_path .. "/pom.xml", function(file) file.write(module_pom) end) then
            notify("Failed to create - " .. mod_path .. "/pom.xml")
            return false
        end
        if not sys.write_to(mod_path .. "/src/main/webapp/WEB-INF/web.xml", function(file) file.write(util.get_web_xml(root_name)) end) then
            notify("Failed to create - " .. mod_path .. "/src/main/webapp/WEB-INF/web.xml")
            return false
        end
        if not sys.write_to(mod_path .. "/src/main/webapp/WEB-INF/beans.xml", function(file) file.write(util.get_beans_xml()) end) then
            notify("Failed to create - " .. mod_path .. "/src/main/webapp/WEB-INF/beans.xml")
            return false
        end
        if not sys.write_to(mod_path .. "/src/main/webapp/WEB-INF/resources.xml", function(file) file.write(util.get_tomee_resource_xml()) end) then
            notify("Failed to create - " .. mod_path .. "/src/main/webapp/WEB-INF/resources.xml")
            return false
        end
        if not sys.write_to(mod_path .. "/src/main/resources/application.properties", function(file) file.write(util.get_application_props()) end) then
            notify("Failed to create - " .. mod_path .. "/src/main/resources/application.properties")
            return false
        end
        if not sys.write_to(mod_path .. "/src/main/resources/META-INF/persistence.xml", function(file) file.write(util.get_persistence_xml()) end) then
            notify("Failed to create - " .. mod_path .. "/src/main/resources/META-INF/persistence.xml")
            return false
        end
        return true
    end
    return false
end

return m
