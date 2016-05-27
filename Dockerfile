# Based on debian jessie (8)
FROM java:8

ENV GRAYLOG_VERSION 2.0.1

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		ca-certificates curl wget software-properties-common apt-transport-https pwgen \
	&& rm -rf /var/lib/apt/lists/*

RUN curl -L https://packages.graylog2.org/releases/graylog/graylog-$GRAYLOG_VERSION.tgz | tar xz -C /opt
RUN ln -s /opt/graylog-$GRAYLOG_VERSION /opt/graylog


RUN mkdir -p /etc/graylog/server
RUN cp /opt/graylog/graylog.conf.example /etc/graylog/server/server.conf
ADD log4j.xml /etc/graylog/server/log4j.xml

ADD docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

VOLUME /opt/graylog/data
