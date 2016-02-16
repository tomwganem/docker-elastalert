#!/bin/bash -e

# Set the timezone.
if [ "$SET_CONTAINER_TIMEZONE" = "true" ]; then
	unlink /etc/localtime
	ln -s /usr/share/zoneinfo/${CONTAINER_TIMEZONE} /etc/localtime && \
	echo "Container timezone set to: $CONTAINER_TIMEZONE"
else
	echo "Container timezone not modified"
fi

if [[ -n "${ELASTICSEARCH_USERNAME:-}" ]]
then
	flags="--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}"
else
	flags=""
fi

if ! curl -f $flags ${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT} >/dev/null 2>&1
then
	echo "Elasticsearch not available at ${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}"
else
	if ! curl -f $flags ${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/elastalert_status >/dev/null 2>&1
	then
		echo "Creating Elastalert index in Elasticsearch..."
	    elastalert-create-index --index elastalert_status --old-index ""
	else
	    echo "Elastalert index already exists in Elasticsearch."
	fi
fi

exec "$@"
