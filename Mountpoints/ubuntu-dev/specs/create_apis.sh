#!/bin/bash

# load variable names
. api_config_variables

# delete the (insecure) authentication API
echo Deleting any old Authentication API \(if it exists\)...
echo
http DELETE kong:8001/apis/$AUTHENTICATE_API_NAME

echo Creating authentication API $AUTHENTICATE_API_NAME
echo

http POST kong:8001/apis \
	name=$AUTHENTICATE_API_NAME \
	upstream_url=$AUTHENTICATE_API_UPSTREAM_URL \
	request_path=$AUTHENTICATE_API_REQUEST_PATH \
	strip_request_path=$AUTHENTICATE_API_STRIP_REQUEST_PATH

# delete the (semi-secure) signup API
echo Deleting any old Signup API \(if it exists\)...
echo
http DELETE kong:8001/apis/$SIGNUP_API_NAME

echo Creating Signup API $SIGNUP_API_NAME
echo

http POST kong:8001/apis \
	name=$SIGNUP_API_NAME \
	upstream_url=$SIGNUP_API_UPSTREAM_URL \
	request_path=$SIGNUP_API_REQUEST_PATH \
	strip_request_path=$SIGNUP_API_STRIP_REQUEST_PATH


# delete secure APIs if they werethere before
echo Deleting any old Secure APIs \(if they exist\)...
echo

# set up an the authentication API
for i in ${SECURE_API_NAMES[@]}; do
    echo deleting ${i} ...
    http DELETE kong:8001/apis/${i}
done

echo Creating new secure APIs...
echo
for i in "${!SECURE_API_NAMES[@]}"; do
    echo creating  ${SECURE_API_NAMES[$i]} ...
    echo proxying to ${SECURE_API_UPSTREAM_URLS[$i]} ...
    echo with request path ${SECURE_API_REQUEST_PATHS[$i]} ...
    echo
    http POST kong:8001/apis \
		name=${SECURE_API_NAMES[$i]} \
		upstream_url=${SECURE_API_UPSTREAM_URLS[$i]} \
		request_path=${SECURE_API_REQUEST_PATHS[$i]} \
		strip_request_path=$SECURE_STRIP_REQUEST_PATH
done

