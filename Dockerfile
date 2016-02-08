# Elastalert Docker image running on Alpine Linux.
# Build image with: docker build -t ivankrizsan/elastalert:latest .
#
# The WORKDIR instructions are deliberately left, as it is recommended to use WORKDIR over the cd command.

FROM iron/python:2

MAINTAINER Tom Ganem, tganem@asperasoft.com

ENV SET_CONTAINER_TIMEZONE false
ENV CONTAINER_TIMEZONE America/Los_Angeles
ENV ELASTALERT_URL https://github.com/Yelp/elastalert/archive/v${ELASTALERT_VERSION}.zip

ENV ELASTALERT_DIRECTORY_NAME elastalert
ENV ELASTALERT_HOME /opt/${ELASTALERT_DIRECTORY_NAME}
ENV ELASTALERT_CONFIG ${ELASTALERT_HOME}/config.yaml
ENV ELASTALERT_RULES ${ELASTALERT_HOME}/rules

ENV ELASTICSEARCH_HOST http://elasticsearch_host
ENV ELASTICSEARCH_PORT 9200
ENV ELASTICSEARCH_INDEX elastalert_status

WORKDIR /opt
ADD start-elastalert.sh ./
RUN chmod +x ./start-elastalert.sh

# Install software required for Elastalert and NTP for time synchronization.
RUN apk update && \
    apk upgrade && \
    apk add python-dev gcc musl-dev tzdata openntpd && \
# Install pip - required for installation of Elastalert.
    wget https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py && \
# Download and unpack Elastalert.
    wget ${ELASTALERT_URL} && \
    unzip *.zip && \
    rm *.zip && \
    mv e* ${ELASTALERT_DIRECTORY_NAME}

WORKDIR ${ELASTALERT_HOME}
RUN python setup.py install && \
    pip install -e . && \

# Install Supervisor.
    easy_install supervisor && \

# Make the start-script executable.
    chmod +x /opt/start-elastalert.sh && \

# Create directories. The /var/empty directory is used by openntpd.
    mkdir ${CONFIG_DIR} && \
    mkdir ${RULES_DIRECTORY} && \
    mkdir ${LOG_DIR} && \
    mkdir /var/empty && \

# Copy default configuration files to configuration directory.
    cp ${ELASTALERT_HOME}/config.yaml.example ${ELASTALERT_CONFIG} && \
    cp ${ELASTALERT_HOME}/supervisord.conf.example ${ELASTALERT_SUPERVISOR_CONF} && \

# Elastalert configuration:
    # Set the rule directory in the Elastalert config file to external rules directory.
    sed -i -e"s|rules_folder: [[:print:]]*|rules_folder: ${RULES_DIRECTORY}|g" ${ELASTALERT_CONFIG} && \
    # Set the Elasticsearch host that Elastalert is to query.
    sed -i -e"s|es_host: [[:print:]]*|es_host: ${ELASTICSEARCH_HOST}|g" ${ELASTALERT_CONFIG} && \
    # Set the port used by Elasticsearch at the above address.
    sed -i -e"s|es_port: [0-9]*|es_port: ${ELASTICSEARCH_PORT}|g" ${ELASTALERT_CONFIG} && \

# Elastalert Supervisor configuration:
    # Redirect Supervisor log output to a file in the designated logs directory.
    sed -i -e"s|logfile=.*log|logfile=${LOG_DIR}/elastalert_supervisord.log|g" ${ELASTALERT_SUPERVISOR_CONF} && \
    # Redirect Supervisor stderr output to a file in the designated logs directory.
    sed -i -e"s|stderr_logfile=.*log|stderr_logfile=${LOG_DIR}/elastalert_stderr.log|g" ${ELASTALERT_SUPERVISOR_CONF} && \
    # Modify the start-command.
    sed -i -e"s|python elastalert.py|python -m elastalert.elastalert --config ${ELASTALERT_CONFIG}|g" ${ELASTALERT_SUPERVISOR_CONF} && \

# Copy the Elastalert configuration file to Elastalert home directory to be used when creating index first time an Elastalert container is launched.
    cp ${ELASTALERT_CONFIG} ${ELASTALERT_HOME}/config.yaml && \

# Clean up.
    apk del python-dev && \
    apk del musl-dev && \
    apk del gcc && \

# Add Elastalert to Supervisord.
    supervisord -c ${ELASTALERT_SUPERVISOR_CONF}

VOLUME [ "${ELASTALERT_CONFIG}", ${ELASTALERT_RULES} ]

ENTRYPOINT ["/opt/start-elastalert.sh"]
CMD [ "python","-m", "elastalert.elastalert", "--config ${ELASTALERT_CONFIG}", "--verbose" ]
