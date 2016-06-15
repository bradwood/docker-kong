#!/bin/bash

# load variable names
. api_config_variables

# note, ACLS not needed for /authenticate or /client as these need to be accessible by anyone

echo Creating new whitelist groups for secure APIs...
echo
for i in "${!SECURE_API_NAMES[@]}"; do
    echo creating whitelist group for  ${SECURE_API_NAMES[$i]} ...
    echo group name: ${SECURE_API_WHITELIST_GROUPS[$i]}
    http -v --form POST kong:8001/apis/${SECURE_API_NAMES[$i]}/plugins \
		name=acl \
		config.whitelist=${SECURE_API_WHITELIST_GROUPS[$i]}
done

