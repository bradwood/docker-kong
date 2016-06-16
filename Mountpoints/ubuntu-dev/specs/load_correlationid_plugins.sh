#!/bin/bash

# load variable names
. api_config_variables

# APIs need to be created first before this script runs (obviously)
echo Installing Correlation ID Plugin for Secure APIs...
echo

for i in "${!SECURE_API_NAMES[@]}"; do
	echo installing Correlation plugin for ${SECURE_API_NAMES[$i]} ...
	http POST kong:8001/apis/${SECURE_API_NAMES[$i]}/plugins \
		name=correlation-id \
		config.header_name=X-Correlation-ID \
		config.generator=uuid#counter \
		config.echo_downstream=$CORRELATION_ID_ECHO_DOWNSTREAM
done

echo Installing Correlation Plugin and loading certificates for Authentication API
echo

echo
http POST kong:8001/apis/$AUTHENTICATE_API_NAME/plugins \
	name=correlation-id \
	config.header_name=X-Correlation-ID \
	config.generator=uuid#counter \
	config.echo_downstream=$CORRELATION_ID_ECHO_DOWNSTREAM


echo Installing Correlation Plugin and loading certificates for CLIENT API
echo

echo
http POST kong:8001/apis/$CLIENT_API_NAME/plugins \
	name=correlation-id \
	config.header_name=X-Correlation-ID \
	config.generator=uuid#counter \
	config.echo_downstream=$CORRELATION_ID_ECHO_DOWNSTREAM
