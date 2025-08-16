local str_dep =
"\n\t\t<dependency>\n\t\t\t<artifactId>%s</artifactId>\n\t\t\t<groupId>%s</groupId>\n\t\t\t<version>%s</version>\n\t\t%s</dependency>"
local str_dep_noversion =
"\n\t\t<dependency>\n\t\t\t<artifactId>%s</artifactId>\n\t\t\t<groupId>%s</groupId>\n\t\t%s</dependency>"
local str_plugin =
"\n\t\t\t<plugin>\n\t\t\t\t<artifactId>%s</artifactId>\n\t\t\t\t<groupId>%s</groupId>\n\t\t\t\t<version>%s</version>%s%s</plugin>"
local str_parent =
"\n\t<parent>\n\t\t<artifactId>%s</artifactId>\n\t\t<groupId>%s</groupId>\n\t\t<version>%s</version>\n\t</parent>"
local str_goal =
"\t<executions>\n\t\t\t\t\t<execution>\n\t\t\t\t\t\t<goals>\n\t\t\t\t\t\t\t<goal>%s</goal>\n\t\t\t\t\t\t</goals>\n\t\t\t\t\t</execution>\n\t\t\t\t</executions>"
local str_multigoal =
"\t<executions>\n\t\t\t\t\t<execution>\n\t\t\t\t\t\t<goals>%s\n\t\t\t\t\t\t</goals>\n\t\t\t\t\t</execution>\n\t\t\t\t</executions>"

local str_pom = [[
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <name>%s</name>
    <groupId>%s</groupId>
    <artifactId>%s</artifactId>
    <version>%s</version>
    <packaging>%s</packaging>%s%s%s%s%s%s%s%s
</project>
]]

local new_xmltag_builder = function(root, tag_level)
    local _childs = ""
    local m1 = {}
    m1.add_child = function(self, name, value)
        local str = string.format("%s<%s>%s</%s>", tag_level .. "\t", name, value, name)
        _childs = _childs .. str
        return self
    end
    m1.add_child_tag = function(self, tag)
        _childs = _childs .. tag
        return self
    end

    m1.build = function(_)
        local str = string.format("%s<%s>%s%s</%s>", tag_level, root, _childs, tag_level, root)
        return str
    end
    return m1
end

-- Detect prj_type from pom.xml: if any module has packaging war, treat as JEE, else JAVA
local function detect_prj_type(pom_path)
    local file = io.open(pom_path, "r")
    if not file then return "JAVA" end
    local content = file:read("*a")
    file:close()
    -- Get module names from <modules>
    local modules = {}
    for mod in content:gmatch("<module>(.-)</module>") do
        table.insert(modules, mod)
    end
    local dir = pom_path:match("(.+)/pom.xml$")
    for _, mod in ipairs(modules) do
        local mod_pom = dir .. "/" .. mod .. "/pom.xml"
        local f = io.open(mod_pom, "r")
        if f then
            local mod_content = f:read("*a")
            f:close()
            if mod_content:find("<packaging>%s*war%s*</packaging>") then
                return "JEE"
            end
        end
    end
    return "JAVA"
end

local new_pom_builder = function()
    local _name, _pkg, _version, _bt
    -- local _props = ""
    -- local _plugins = ""
    local _properties_builder = nil
    local _plugins_builder = nil
    local _report_plugins_builder = nil
    local _modules_builder = nil
    local _deps = ""
    local _dm = ""
    local _dm_end = ""
    local _parent = ""
    local m = {}
    m.setName = function(self, name)
        _name = name
        return self
    end
    m.setPkg = function(self, name)
        _pkg = name
        return self
    end
    m.setVersion = function(self, name)
        _version = name
        return self
    end
    m.setModuleType = function(self, name)
        _bt = name
        if name == "pom" then
            _dm = "\n\t<dependencyManagement>"
            _dm_end = "\n\t</dependencyManagement>"
        end
        return self
    end
    m.addProp = function(self, name, value)
        if _properties_builder == nil then
            _properties_builder = new_xmltag_builder("properties", "\n\t")
        end
        _properties_builder:add_child(name, value)
        return self
    end
    m.addDependancy = function(self, name, grp, version, scope)
        local scope_str = ""
        if scope ~= "" then
            scope_str = string.format("\t<scope>%s</scope>%s", scope, "\n\t\t")
        end
        local str = string.format(str_dep, name, grp, version, scope_str)
        _deps = _deps .. str
        return self
    end
    m.addDependancyMin = function(self, name, grp, scope)
        local scope_str = ""
        if scope ~= "" then
            scope_str = string.format("\t<scope>%s</scope>%s", scope, "\n\t\t")
        end
        local str = string.format(str_dep_noversion, name, grp, scope_str)
        _deps = _deps .. str
        return self
    end
    m.addModule = function(self, name)
        if _modules_builder == nil then
            _modules_builder = new_xmltag_builder("modules", "\n\t")
        end
        _modules_builder:add_child("module", name)
        return self
    end
    m.addPlugin = function(self, name, grp, version, config, goal)
        if _plugins_builder == nil then
            _plugins_builder = new_xmltag_builder("plugins", "\n\t\t")
        end
        local hasGoal = (goal ~= nil and goal ~= "")
        local hasConfig = (config ~= nil and config ~= "")
        if hasConfig == true then
            -- Adjust indentetion if goal is provided
            if hasGoal == true then
                config = config .. "\n\t\t\t"
            end
        end

        -- Indent last end tag
        local goal_xml = "\n\t\t\t"
        if hasGoal == true then
            if type(goal) == "table" then
                local mutigoal_xml = ""
                for _, goal_item in pairs(goal) do
                    mutigoal_xml = mutigoal_xml .. string.format("\n\t\t\t\t\t\t\t<goal>%s</goal>", goal_item)
                end
                if mutigoal_xml ~= "" then
                    goal_xml = string.format(str_multigoal, mutigoal_xml) .. "\n\t\t\t"
                end
            else
                goal_xml = string.format(str_goal, goal) .. "\n\t\t\t"
            end
            -- Adjust indentetion if config is empty
            if hasConfig == false then
                goal_xml = "\n\t\t\t" .. goal_xml
            end
        end
        local plug_xml = string.format(str_plugin, name, grp, version, config, goal_xml)
        _plugins_builder:add_child_tag(plug_xml)
        return self
    end
    m.addReportPlugin = function(self, name, grp, version, config, goal)
        if _report_plugins_builder == nil then
            _report_plugins_builder = new_xmltag_builder("plugins", "\n\t\t")
        end
        local hasGoal = (goal ~= nil and goal ~= "")
        local hasConfig = (config ~= nil and config ~= "")
        if hasConfig == true then
            -- Adjust indentetion if goal is provided
            if hasGoal == true then
                config = config .. "\n\t\t\t"
            end
        end

        -- Indent last end tag
        local gg = "\n\t\t\t"
        if hasGoal == true then
            gg = string.format(str_goal, goal) .. "\n\t\t\t"
            -- Adjust indentetion if config is empty
            if hasConfig == false then
                gg = "\n\t\t\t" .. gg
            end
        end
        local str = string.format(str_plugin, name, grp, version, config, gg)
        _report_plugins_builder:add_child_tag(str)
        return self
    end
    m.addPluginMid = function(self, name, grp, version, config)
        self:addPlugin(name, grp, version, config, "")
        return self
    end
    m.addPluginMin = function(self, name, grp, version)
        self:addPlugin(name, grp, version, "", "")
        return self
    end
    m.setParent = function(self, name, pkg, version)
        _parent = string.format(str_parent, name, pkg, version)
        return self
    end
    m.build = function(_)
        local props = ""
        local plugins = ""
        local reportPlug = ""
        local modules = ""
        local deps = new_xmltag_builder("dependencies", "\n\t"):add_child_tag(_deps):build()
        if _properties_builder ~= nil then props = _properties_builder:build() end
        if _plugins_builder ~= nil then
            plugins = new_xmltag_builder("build", "\n\t"):add_child_tag(_plugins_builder:build()):build()
        end
        if _report_plugins_builder ~= nil then
            reportPlug = new_xmltag_builder("reporting", "\n\t"):add_child_tag(_report_plugins_builder:build()):build()
        end
        if _modules_builder ~= nil then
            modules = _modules_builder:build()
        end
        return string.format(str_pom, _name, _pkg, _name, _version, _bt, _parent, props, _dm, deps, _dm_end, plugins,
            reportPlug, modules);
    end
    return m
end

-- Utility: parse_pom_info
local function parse_pom_info(pom_path)
    local info = {}
    local file = io.open(pom_path, "r")
    if not file then return nil end
    local content = file:read("*a")
    file:close()
    info.groupId = content:match("<groupId>(.-)</groupId>")
    info.artifactId = content:match("<artifactId>(.-)</artifactId>")
    info.version = content:match("<version>(.-)</version>")
    return info
end

local function build_main_pom(name, grp, version, prj_type, modules)
    local builder = new_pom_builder()
    builder:setName(name):setPkg(grp):setVersion(version)
    builder:addProp("project.build.sourceEncoding", "UTF-8")
    builder:addProp("skipTests", "true")
    builder:addProp("skipOwasp", "true")
    builder:addProp("skipPmd", "true")
    builder:addProp("rootBase", "${session.executionRootDirectory}")
    builder:addProp("maven.compiler.source", "21")
    builder:addProp("maven.compiler.target", "21")
    builder:setModuleType("pom")

    -- Add plugins
    local plug_config_builder = new_xmltag_builder("configuration", "\n\t\t\t\t")
    plug_config_builder:add_child("skipTests", "${skipTests}")
    builder:addPluginMid("maven-surefire-plugin", "org.apache.maven.plugins", "3.5.3", plug_config_builder:build())

    builder:addPluginMin("maven-compiler-plugin", "org.apache.maven.plugins", "3.14.0")
    builder:addPluginMin("maven-install-plugin", "org.apache.maven.plugins", "3.1.4")
    builder:addPluginMin("maven-jar-plugin", "org.apache.maven.plugins", "3.4.2")
    builder:addPluginMin("maven-clean-plugin", "org.apache.maven.plugins", "3.5.0")
    builder:addPluginMin("maven-release-plugin", "org.apache.maven.plugins", "3.1.1")

    local owasp_config = new_xmltag_builder("configuration", "\n\t\t\t\t")
    owasp_config:add_child("skip", "${skipOwasp}")
    builder:addPlugin("dependency-check-maven", "org.owasp", "12.1.1", owasp_config:build(), "check")

    local pmd_config = new_xmltag_builder("configuration", "\n\t\t\t\t")
    pmd_config:add_child("skip", "${skipPmd}")
    pmd_config:add_child("failOnViolation", "false")
    pmd_config:add_child("printFailingErrors", "true")
    pmd_config:add_child("targetJdk", "17")
    pmd_config:add_child("rulesets", "<ruleset>${rootBase}/pmd-rules.xml</ruleset>")
    builder:addPlugin("maven-pmd-plugin", "org.apache.maven.plugins", "3.26.0", pmd_config:build(),
        { "check", "cpd-check" })
    builder:addReportPlugin("maven-jxr-plugin", "org.apache.maven.plugins", "3.6.0", "", "")
    -- removed stray tag_level line
    if prj_type == "JEE" then
        builder:addPlugin("maven-war-plugin", "org.apache.maven.plugins", "3.4.0", "")
    end

    -- Add dependencies
    builder:addDependancy("slf4j-api", "org.slf4j", "2.0.17", "")
    builder:addDependancy("logback-core", "ch.qos.logback", "1.5.18", "")
    builder:addDependancy("logback-classic", "ch.qos.logback", "1.5.18", "")
    -- Test
    builder:addDependancy("mockito-core", "org.mockito", "5.16.1", "test")
    builder:addDependancy("mockito-junit-jupiter", "org.mockito", "5.16.1", "test")
    builder:addDependancy("junit-jupiter-api", "org.junit.jupiter", "5.12.1", "test")
    -- JEE
    if prj_type == "JEE" then
        builder:addDependancy("jakarta.jakartaee-api", "jakarta.platform", "10.0.0", "provided")
    end

    -- DB
    builder:addDependancy("sqlite-jdbc", "org.xerial", "3.49.1.0", "")
    -- builder:addDependancy("h2", "com.h2database", "2.3.232", "")
    if type(modules) == "table" then
        for _, value in pairs(modules) do
            builder:addModule(value)
        end
    end
    return builder:build()
end

local function build_module_pom(prj_type, module_type, name, grp, version, parent_name, parent_pkg, parent_version, deps)
    local builder = new_pom_builder()
    builder:setName(name):setPkg(grp):setVersion(version)
    builder:setParent(parent_name, parent_pkg, parent_version)
    if module_type == "war" then
        builder:setModuleType("war")
        builder:addProp("failOnMissingWebXml", "false")
    else
        builder:setModuleType("jar")
        if prj_type == "JEE" then
            builder:addDependancyMin("jakarta.jakartaee-api", "jakarta.platform", "provided")
            builder:addDependancyMin("slf4j-api", "org.slf4j", "")
            builder:addDependancyMin("logback-core", "ch.qos.logback", "")
            builder:addDependancyMin("logback-classic", "ch.qos.logback", "")
            builder:addDependancyMin("sqlite-jdbc", "org.xerial", "")
            -- builder:addDependancyMin("h2", "com.h2database", "")
        end
        -- Add dependencies
        -- Test
        builder:addDependancyMin("mockito-core", "org.mockito", "test")
        builder:addDependancyMin("mockito-junit-jupiter", "org.mockito", "test")
        builder:addDependancyMin("junit-jupiter-api", "org.junit.jupiter", "test")
    end
    if deps ~= nil and type(deps) == "table" then
        for _, value in pairs(deps) do
            if type(value) == "table" then
                local mname, mpkg, mscope, mversion
                for key, v in pairs(value) do
                    if key == "name" then
                        mname = v
                    elseif key == "scope" then
                        mscope = v
                    elseif key == "pkg" then
                        mpkg = v
                    elseif key == "version" then
                        mversion = v
                    end
                end
                builder:addDependancy(mname, mpkg, mversion, mscope)
            end
        end
    end
    return builder:build()
end

return {
    build_main_pom = build_main_pom,
    build_module_pom = build_module_pom,
    parse_pom_info = parse_pom_info,
    detect_prj_type = detect_prj_type
}
