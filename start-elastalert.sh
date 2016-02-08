#!/bin/sh

set -e

# Set the timezone.
if [ "$SET_CONTAINER_TIMEZONE" = "true" ]; then
	setup-timezone -z ${CONTAINER_TIMEZONE} && \
	echo "Container timezone set to: $CONTAINER_TIMEZONE"
else
	echo "Container timezone not modified"
fi

# Force immediate synchronisation of the time and start the time-synchronization service.
# In order to be able to use ntpd in the container, it must be run with the SYS_TIME capability.
# In addition you may want to add the SYS_NICE capability, in order for ntpd to be able to modify its priority.
ntpd -s

# Check if the Elastalert index exists in Elasticsearch and create it if it does not.

if curl -f ${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT} > /dev/null 2>&1; then
  if ! curl -f ${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/${ELASTICSEARCH_INDEX} > /dev/null 2>&1; then
    echo "Creating Elastalert index in Elasticsearch..."
    elastalert-create-index --index ${ELASTICSEARCH_INDEX} --old-index ""
  else
    echo "Elastalert index already exists in Elasticsearch."
 fi
fi

exec "$@"
