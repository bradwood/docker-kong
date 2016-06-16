#!/bin/bash

# This script will call the auth API a load of times to test if the rate limit kicks in.

# load variable names
. api_config_variables

i=1

while true; do # repeat forever
	echo Count=$i
	time http --verify=no --check-status -v POST https://kong:8443/authenticate/$API_VERSION \
		client_id=$MOB_CLIENT_ID \
		client_secret=$MOB_CLIENT_SECRET \
		scope=${SECURE_API_REQUEST_PATHS[0]}/$API_VERSION \
		username=$AUTH_USERNAME \
		password=$AUTH_PASSWORD

	if (( $? != 0)); then
		exit 1
	fi
	i=$(expr $i + 1)
done
