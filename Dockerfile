FROM graylog/graylog:3.2.4-1

RUN curl -L --retry 3 --output "/usr/share/graylog/plugin/graylog-plugin-auth-sso-3.2.1.jar" \
"https://github.com/Graylog2/graylog-plugin-auth-sso/releases/download/3.2.1/graylog-plugin-auth-sso-3.2.1.jar"
# RUN mkdir -p /opt/geolite && curl -L --retry 3 "http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz" | tar xvz --strip-components=1 -C /opt/geolite
# ADD log4j.xml /etc/graylog/server/log4j.xml
