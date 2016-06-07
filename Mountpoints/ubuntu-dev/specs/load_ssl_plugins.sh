#!/bin/bash

# load variable names
. api_config_variables

# APIs need to be created first before this script runs (obviously)
echo Installing SSL Plugin and loading certificates for Secure APIs...
echo

for i in "${!SECURE_API_NAMES[@]}"; do
	echo installing SSL plugin for ${SECURE_API_NAMES[$i]} ...
	http POST kong:8001/apis/${SECURE_API_NAMES[$i]}/plugins \
		name=ssl \
		config.cert=@./server.crt \
		config.key=@./server.key \
		config.only_https=true
done

echo Installing SSL Plugin and loading certificates for authentication API
echo

echo
http POST kong:8001/apis/$AUTHENTICATE_API_NAME/plugins \
	name=ssl \
	config.cert=@./server.crt \
	config.key=@./server.key \
	config.only_https=true
