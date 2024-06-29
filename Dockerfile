FROM tomcat:10.0
COPY target/simple-webapp.war /usr/local/tomcat/webapps/
