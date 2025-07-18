local m = {}
m.find_src_paths = (function()
    local function scan_dir_for_src(parent_dir, paths, is_mvn_prj, cur_level)
        -- To avoid searching above the max-dept. It will help when
        -- when current directory has huge directory depth. Any way we didnt expect sub-projects at
        -- depth gretor than 5.
        if cur_level > 6 then return end
        local file_names = vim.fn.readdir(parent_dir)
        if file_names == nil then return end
        for _, file in ipairs(file_names) do
            -- if list has any hidden directory, skip it.
            if string.len(file) > 0 and string.sub(file, 1, 1) ~= "." then
                local cur_file_path = parent_dir .. "/" .. file
                if 1 == vim.fn.isdirectory(cur_file_path) then
                    -- directory name is src/SRC/Src and it to the
                    -- output list
                    if file == "src" then
                        local add_src = true
                        -- If this is maven project, we need to check if project has following structure.
                        -- If yes, add these following directories as src directory
                        -- ----------------------------------------------------------
                        -- src-+
                        --     |
                        --     +- main
                        --     |    |
                        --     +    +- java
                        --     |
                        --     +- test
                        --          |
                        --          +- java
                        -- In other cases, add src only
                        -- ----------------------------------------------------------
                        if is_mvn_prj == true then
                            if 1 == vim.fn.isdirectory(cur_file_path .. "/main/java") then
                                table.insert(paths, cur_file_path .. "/main/java")
                                add_src = false
                            end
                            if 1 == vim.fn.isdirectory(cur_file_path .. "/test/java") then
                                table.insert(paths, cur_file_path .. "/test/java")
                                add_src = false
                            end
                        end
                        if add_src == true then
                            table.insert(paths, cur_file_path)
                        end
                        -- Else cotinue search for src directory
                    else
                        scan_dir_for_src(cur_file_path, paths, is_mvn_prj, cur_level + 1)
                    end
                end
            end
        end
    end

    local paths = {}
    return function(input_dir, return_existing, reset)
        local tbl_len = require("core.util.table").len;
        if return_existing ~= nil and return_existing == true and tbl_len(paths) > 0 then
            return paths
        end
        if reset ~= nil and reset == true then
            paths = {}
        end
        if input_dir ~= nil then
            local sys = require("core.util.sys")
            local is_mvn_prj = sys.is_file(input_dir .. "/" .. "pom.xml")
            scan_dir_for_src(input_dir, paths, is_mvn_prj, 1)
        end
        return paths
    end
end)()

m.get_ignore_content = function()
    return [[
trash/**
Servers/**
target/**
*.tar.gz
.metadata/**
.settings/**
**/target/**
**/.metadata/**
**/.settings/**
.nvim/**
.classpath
.project
*.trc
*.phd
]]
end

m.get_application_props = function()
    return ""
end

m.get_persistence_xml = function()
    local xml = [[
<?xml version="1.0" encoding="UTF-8"?>
<persistence version="2.2"
	xmlns="http://xmlns.jcp.org/xml/ns/persistence"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/persistence http://xmlns.jcp.org/xml/ns/persistence/persistence_2_2.xsd">
	<persistence-unit name="development" transaction-type="JTA">
        <provider>org.eclipse.persistence.jpa.PersistenceProvider</provider>
        <jta-data-source>myapp/managed</jta-data-source>
	    <!-- 
        <non-jta-data-source>myapp/unmanaged</non-jta-data-source> 
        <class>valide class-name</class> 
        -->
		<exclude-unlisted-classes>false</exclude-unlisted-classes>
		<properties>
			<!-- <property
                name="jakarta.persistence.schema-generation.database.action"
			    value="drop-and-create" /> -->
            <property name="eclipselink.logging.level" value="FINE"/>
            <property name="eclipselink.ddl-generation" value="drop-and-create-tables"/>
		</properties>		
	</persistence-unit>
</persistence>
    ]]
    return xml
end

m.get_beans_xml = function()
    local xml = [[
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="https://jakarta.ee/xml/ns/jakartaee"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="https://jakarta.ee/xml/ns/jakartaee
                           https://jakarta.ee/xml/ns/jakartaee/beans_3_0.xsd"
       version="3.0" bean-discovery-mode="all">
</beans>
    ]]
    return xml
end

m.get_tomee_resource_xml = function()
    local xml = [[
<?xml version="1.0" encoding="UTF-8"?>
<tomee>
    <Resource id="myapp/managed" type="DataSource">
        JdbcDriver = org.sqlite.JDBC
        JdbcUrl = jdbc:sqlite:./myapp.db
        UserName = sa
        Password = sa
        jtaManaged = true
    </Resource>
</tomee>
    ]]
    return xml
end

m.get_web_xml = function(app_name)
    local xml = [[
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE web-app PUBLIC '-//Sun Microsystems, Inc.//DTD Web
Application 2.3//EN' 'http://java.sun.com/dtd/web-app_2_3.dtd'>
<web-app>
    <display-name>]] .. app_name .. [[</display-name>
</web-app>
    ]]
    return xml
end

return m
