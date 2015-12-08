# Elastalert Docker image running on Ubuntu 14.04.
# Based off of ivankrizsan/elastalert

FROM python:3.5.0-slim
ENV ELASTALERT_VERSION 0.0.70

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
RUN apt-get update && \
    apt-get install -y curl unzip ntp gcc && \
    curl -Lo elastalert.zip ${ELASTALERT_URL} && \
    unzip *.zip && \
    rm *.zip && \
    mv e* ${ELASTALERT_DIRECTORY_NAME}

WORKDIR ${ELASTALERT_HOME}
RUN python setup.py install && \
    pip install -e .

VOLUME [ "${ELASTALERT_CONFIG}", ${ELASTALERT_RULES} ]

ENTRYPOINT ["/opt/start-elastalert.sh"]
CMD [ "python","-m", "elastalert.elastalert", "--config ${ELASTALERT_CONFIG}", "--verbose" ]
