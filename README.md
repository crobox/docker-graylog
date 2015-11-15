# Graylog server and web-interface docker image

Docker image containing only the Graylog server and web interface, you need to setup MongoDB and Elasticsearch in seperate envirnments and configure them respectivly (using environment variables)
```
$ docker pull sagent/graylog
$ docker run -t -p 9000:9000 -p 12201:12201 -p 12201:12201/udp sagent/graylog
```

To run the container in the background replace `-t` with `-d`.

Usage
-----

After starting the container, your Graylog instance is ready to use.
You can reach the web interface by pointing your browser to the IP address of your Docker host: `http://<host IP>:9000`

The default login is Username: `admin`, Password: `admin`.

How to get log data in
----------------------

You can create different kinds of inputs under *System -> Inputs*, however you can only use ports that have been properly
mapped to your docker container, otherwise data will not get through. You already exposed the default GELF port 12201, so
it is a good idea to start a GELF TCP input there.

To start another input you have to expose the right port e.g. to start a raw TCP input on
port 5555; stop your container and recreate it, whilst appending `-p 5555:5555` to your run argument. Similarly, the
same can be done for UDP by appending `-p 5555:5555/udp` option. Then you can send raw text to Graylog like
`echo 'first log message' | nc localhost 5555`

Additional options
------------------

You can configure the most important aspects of your Graylog instance through environment variables. In order
to set a variable add a `-e VARIABLE_NAME` option to your `docker run` command. For example to set another admin password
start your container like this::
```
$ docker run -t -p 9000:9000 -p 12201:12201 -p 12201:12201/udp -e GRAYLOG_PASSWORD=SeCuRePwD sagent/graylog
```

Variable Name        | Configuration Option
---------------------|---------------------------
GRAYLOG_PASSWORD     | Set admin password
GRAYLOG_SMTP_SERVER  | Hostname/IP address of your SMTP server for sending alert mails
GRAYLOG_SMTP_PORT    | Port of your SMTP server
GRAYLOG_SMTP_USER    | User to use for SMTP
GRAYLOG_SMTP_PASSWORD|Password to use for SMTP
GRAYLOG_RETENTION_INDICES | Configure how many indices should be kept(default: 20) an index is max 4GB each
GRAYLOG_ES_PREFIX    | Prefix for all Elasticsearch indices and index aliases managed by Graylog.
GRAYLOG_ES_CLUSTER   | Name of the cluster.name of Elasticsearch (default: graylog)
GRAYLOG_ES_NODES     | Comma separated list of Elasticsearch nodes (example: esnode1:9300,esnode2:9300)
GRAYLOG_MONGO_URI    | Mongo URI of the MongoDB node (example: mongodb://mongo:27017/graylog)
GRAYLOG_NODE_ID      | Set server node ID (default: random)
GRAYLOG_SERVER_SECRET| Set salt for encryption

