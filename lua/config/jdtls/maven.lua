local m = {}

m.get_pom = function(_, type, package, version, name)
    if package == nil then package = "{}" end
    if version == nil then version = "{}" end
    if name == nil then name = "{}" end

    local build_type = "jar"
    local deps = ""
    local plugin = ""
    if type == "javaee" then
        build_type = "war"
        deps = [[
		<dependency>
			<groupId>jakarta.platform</groupId>
			<artifactId>jakarta.jakartaee-api</artifactId>
			<version>10.0.0</version>
			<scope>provided</scope>
		</dependency>
        ]]
        plugin = [[
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-war-plugin</artifactId>
            <version>3.4.0</version>
        </plugin>
        ]]
    end

    local str_pom = [[
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<groupId>]] .. package .. [[</groupId>
	<artifactId>]] .. name .. [[</artifactId>
	<version>]] .. version .. [[</version>
	<name>]] .. name .. [[</name>
    <packaging>]] .. build_type .. [[</packaging>
	<properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
		<failOnMissingWebXml>false</failOnMissingWebXml>
	</properties>
	<dependencies>
    ]] .. deps .. [[
		<dependency>
			<groupId>org.mockito</groupId>
			<artifactId>mockito-core</artifactId>
			<version>5.11.0</version>
			<scope>test</scope>
		</dependency>
		<dependency>
			<groupId>junit</groupId>
			<artifactId>junit</artifactId>
			<version>4.13.2</version>
			<scope>test</scope>
		</dependency>
	</dependencies>
	<build>
		<plugins>
			<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-compiler-plugin</artifactId>
				<version>3.13.0</version>
				<configuration>
					<source>17</source>
					<target>17</target>
					<showWarnings>true</showWarnings>
					<debug>true</debug>
				</configuration>
			</plugin>
			<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-surefire-plugin</artifactId>
				<version>3.3.1</version>
			</plugin>
            ]] .. plugin .. [[<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-install-plugin</artifactId>
				<version>3.1.2</version>
			</plugin>
			<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-jar-plugin</artifactId>
				<version>3.4.2</version>
			</plugin>
			<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-clean-plugin</artifactId>
				<version>3.4.0</version>
			</plugin>
			<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-release-plugin</artifactId>
				<version>3.1.0</version>
			</plugin>
		</plugins>
		<pluginManagement>
		</pluginManagement>
	</build>
</project>
    ]]
    return str_pom
end

m.create_prj = function(self, type, root_dir)
    local root_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
    local is_jee = (type == "javaee")
    local sys = require("core.util.sys")
    if sys.is_dir(root_dir .. "/src") then
        print("Failed to create project - /src already exit")
        return
    end
    local dirs_needed = {}
    dirs_needed[0] = root_dir .. "/src"
    dirs_needed[1] = root_dir .. "/src/main"
    dirs_needed[2] = root_dir .. "/src/test"
    dirs_needed[3] = root_dir .. "/src/main/java"
    dirs_needed[4] = root_dir .. "/src/main/resources"
    dirs_needed[5] = root_dir .. "/src/test/java"
    dirs_needed[6] = root_dir .. "/src/test/resources"
    if is_jee then
        dirs_needed[7] = root_dir .. "/src/main/resources/META-INF"
        dirs_needed[8] = root_dir .. "/src/main/webapp"
        dirs_needed[9] = root_dir .. "/src/main/webapp/WEB-INF"
    end
    if sys.create_dirs(dirs_needed) then
        local pom_content = self:get_pom(type, "com.nnj.learn", "0.0.1", root_name)
        local st = sys.write_to(root_dir .. "/pom.xml", function(file)
            file.write(pom_content)
        end)
        if not st then
            print("Failed to create - " .. root_dir .. "/pom.xml")
            return
        end
    end
end

return m
