FROM graylog2/server:2.3.1-1

RUN wget -O /usr/share/graylog/plugin/graylog-plugin-auth-sso-2.3.0.jar https://github.com/Graylog2/graylog-plugin-auth-sso/releases/download/2.3.0/graylog-plugin-auth-sso-2.3.0.jar

# ADD log4j.xml /etc/graylog/server/log4j.xml