local m = {}

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
	<persistence-unit name="prod" transaction-type="JTA">
		<exclude-unlisted-classes>false</exclude-unlisted-classes>
		<properties>
			<property
                name="jakarta.persistence.schema-generation.database.action"
			    value="drop-and-create" />
		</properties>		
	</persistence-unit>
</persistence>
    ]]
    return xml
end

m.get_beans_xml = function()
    local xml = [[
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://xmlns.jcp.org/xml/ns/javaee"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/beans_1_1.xsd"
    bean-discovery-mode="all">
</beans>
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
