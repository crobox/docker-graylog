#!/bin/bash
set -ex

CONFIG_FILE=/etc/graylog/server/server.conf

sed -i -e "s/password_secret =\s*$/password_secret = ${GRAYLOG_SERVER_SECRET:=$(pwgen -s 96)}/" $CONFIG_FILE
sed -i -e "s/rest_listen_uri =.*$/rest_listen_uri = http:\/\/0.0.0.0:12900\//" $CONFIG_FILE

if [ ! -z "$GRAYLOG_PASSWORD" ]; then
	sed -i -e "s/root_password_sha2 =$/root_password_sha2 = $(echo -n $GRAYLOG_PASSWORD | sha256sum | awk '{print $1}')/" $CONFIG_FILE
fi
if [ ! -z "$GRAYLOG_SMTP_SERVER" ]; then
	sed -i -e "s/#transport_email_enabled = false/transport_email_enabled = true/" $CONFIG_FILE
	sed -i -e "s/#transport_email_use_auth =.*$/transport_email_use_auth = true/" $CONFIG_FILE
	sed -i -e "s/#transport_email_use_tls =.*$/transport_email_use_tls = true/" $CONFIG_FILE
	sed -i -e "s/#transport_email_use_ssl =.*$/transport_email_use_ssl = true/" $CONFIG_FILE
	sed -i -e "s/#transport_email_subject_prefix =.*$/transport_email_subject_prefix = [graylog]/" $CONFIG_FILE
	sed -i -e "s/#transport_email_hostname =.*$/transport_email_hostname = $GRAYLOG_SMTP_SERVER/" $CONFIG_FILE
fi
if [ ! -z "$GRAYLOG_SMTP_PORT" ]; then
	sed -i -e "s/#transport_email_port =.*$/transport_email_port = $GRAYLOG_SMTP_PORT/" $CONFIG_FILE
fi
if [ ! -z "$GRAYLOG_SMTP_USER" ]; then
	sed -i -e "s/#transport_email_auth_username =.*$/transport_email_auth_username = $GRAYLOG_SMTP_USER/" $CONFIG_FILE
fi
if [ ! -z "$GRAYLOG_SMTP_PASSWORD" ]; then
	sed -i -e "s/#transport_email_auth_password =.*$/transport_email_auth_password = $GRAYLOG_SMTP_PASSWORD/" $CONFIG_FILE
fi

if [ ! -z "$GRAYLOG_RETENTION_INDICES" ]; then
	sed -i -e "s/rotation_strategy =.*$/rotation_strategy = size/" $CONFIG_FILE
	sed -i -e "s/elasticsearch_max_docs_per_index =.*$/#elasticsearch_max_docs_per_index = /" $CONFIG_FILE
	sed -i -e "s/#elasticsearch_max_size_per_index =.*$/elasticsearch_max_size_per_index = 4294967296/" $CONFIG_FILE
	sed -i -e "s/elasticsearch_max_number_of_indices =.*$/elasticsearch_max_number_of_indices = $GRAYLOG_RETENTION_INDICES/" $CONFIG_FILE
fi

if [ ! -z "$GRAYLOG_ES_SHARDS" ]; then
	sed -i -e "s/elasticsearch_shards =.*$/elasticsearch_shards = $GRAYLOG_ES_SHARDS/" $CONFIG_FILE
fi

if [ ! -z "$GRAYLOG_ES_REPLICAS" ]; then
	sed -i -e "s/elasticsearch_replicas =.*$/elasticsearch_replicas = $GRAYLOG_ES_REPLICAS/" $CONFIG_FILE
fi

if [ ! -z "$GRAYLOG_ES_PREFIX" ]; then
	sed -i -e "s/elasticsearch_index_prefix =.*$/elasticsearch_index_prefix = $GRAYLOG_ES_PREFIX/" $CONFIG_FILE
fi

if [ ! -z "$GRAYLOG_ES_CLUSTER" ]; then
	sed -i -e "s/#elasticsearch_cluster_name =.*$/elasticsearch_cluster_name = $GRAYLOG_ES_CLUSTER/" $CONFIG_FILE
fi

if [ ! -z "$GRAYLOG_ES_NODES" ]; then
	sed -i -e "s/#elasticsearch_discovery_zen_ping_multicast_enabled =.*$/elasticsearch_discovery_zen_ping_multicast_enabled = false/" $CONFIG_FILE
	sed -i -e "s/#elasticsearch_discovery_zen_ping_unicast_hosts =.*$/elasticsearch_discovery_zen_ping_unicast_hosts = $GRAYLOG_ES_NODES/" $CONFIG_FILE
fi

if [ ! -z "$GRAYLOG_MONGO_URI" ]; then
	sed -i -e "s\mongodb_uri =.*$\mongodb_uri = $GRAYLOG_MONGO_URI\\" $CONFIG_FILE
fi

if [ ! -z "$GRAYLOG_NODE_ID" ]; then
	echo $GRAYLOG_NODE_ID > /etc/graylog/server/node-id
fi
# if [ ! -z "$GRAYLOG_MASTER" ]; then
# 	graylog-ctl set-cluster-master $GRAYLOG_MASTER
# fi
# Set heap to different value if specified
if [ ! -z "$GRAYLOG_MEMORY" ]; then
	sed -i -- "s/Xms1g/Xms$GRAYLOG_MEMORY/g" /opt/graylog-server/bin/graylogctl 
	sed -i -- "s/Xmx1g/Xmx$GRAYLOG_MEMORY/g" /opt/graylog-server/bin/graylogctl
fi

WEB_CONFIG_FILE=/opt/graylog-web-interface/conf/graylog-web-interface.conf
sed -i -e "s/application.secret=.*$/application.secret=\"${GRAYLOG_SERVER_SECRET:=$(pwgen -s 96)}\"/" $WEB_CONFIG_FILE
sed -i -e "s@graylog2-server.uris=.*@graylog2-server.uris=\"http://localhost:12900/\"@" $WEB_CONFIG_FILE
sed -i -e "s/timeout.DEFAULT.*$/timeout.DEFAULT=15s/" $WEB_CONFIG_FILE
/opt/graylog-web-interface/bin/graylog-web-interface &


/opt/graylog-server/bin/graylogctl run
