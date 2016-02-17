# Elastalert Docker image running on ubuntu
# Based off of ivankrizsan/elastalert:latest .
FROM ubuntu:14.04

MAINTAINER Tom Ganem
ENV SET_CONTAINER_TIMEZONE true
ENV ELASTALERT_VERSION 0.0.75
ENV CONTAINER_TIMEZONE America/Los_Angeles
ENV ELASTALERT_URL https://github.com/Yelp/elastalert/archive/v${ELASTALERT_VERSION}.tar.gz
ENV ELASTALERT_DIRECTORY_NAME elastalert
ENV ELASTALERT_HOME /opt/${ELASTALERT_DIRECTORY_NAME}
ENV RULES_DIRECTORY /opt/${ELASTALERT_DIRECTORY_NAME}/rules

ENV ELASTICSEARCH_HOST http://elasticsearch
ENV ELASTICSEARCH_PORT 9200
ENV ELASTICSEARCH_USERNAME ""
ENV ELASTICSEARCH_PASSWORD ""
ENV ELASTALERT_VERSION_CONSTRAINT "elasticsearch>=1.0.0,<2.0.0"

WORKDIR /opt

RUN apt-get update && \
    apt-get install tar curl python-dev tzdata -y

RUN curl -Lo get-pip.py https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py

RUN mkdir -p ${ELASTALERT_HOME}

RUN curl -Lo elastalert.tar.gz ${ELASTALERT_URL} && \
    tar xvf *.tar.gz -C ${ELASTALERT_HOME} --strip-components 1 && \
    rm *.tar.gz

WORKDIR ${ELASTALERT_HOME}

RUN mkdir -p ${RULES_DIRECTORY}
RUN sed -i -e "s|'elasticsearch'|'${ELASTALERT_VERSION_CONSTRAINT}'|g" setup.py
RUN python setup.py install && \
    pip install -e .

COPY ./start-elastalert.sh /opt/start-elastalert.sh
RUN chmod +x /opt/start-elastalert.sh

ENTRYPOINT ["/opt/start-elastalert.sh"]
CMD ["/usr/bin/python", "-m", "elastalert.elastalert", "--verbose"]
