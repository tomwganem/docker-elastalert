# Elastalert Docker Image
Docker image with Elastalert built on an ubuntu image.
Based off of ivankrizsan/elastalert. Modified to integrate better with a
Mesos/Marathon environment.

Mount your rules at `/opt/elastalert/rules` and your config file at
`/opt/elastalert/config.yaml`

# Environment Variables

What the container is started, it will try to connect to an elaticsearch
instance using the below environment variables. It will create an elastalert
index for you if it detects that you missing it.

* `ELASTALERT_HOST` - url for elasticsearch host.
 Default is http://elasticsearch
* `ELASTICSEARCH_PORT` - port for elasticsearch host.
 Default is 9200
* `ELASTICSEARCH_USERNAME` - Set if your elasticsearch uses basic auth.
 Empty by Default.
* `ELASTICSEARCH_PASSWORD` - Set if your elasticsearch uses basic auth.
 Empty by default.

Other Environment Variables include:
* `ELASTALERT_VERSION_CONSTRAINT` - If you are using a version of elasticsearch
 that is not the latest, you should modify this so that you install the correct
 elasticsearch-py library (this value will be inserted into setup.py).
 For example, to use elastalert with elasticsearch 1.7.0,
 you should set this to `elasticsearch<=1.7.0` Default value is `elasticsearch`.
* `SET_CONTAINER_TIMEZONE` - Set to "true" (without quotes) to set the tiemzone
 when starting a container. Default is false.
* `CONTAINER_TIMEZONE` - Timezone to use in container.
 Default is America/Los_Angeles.
