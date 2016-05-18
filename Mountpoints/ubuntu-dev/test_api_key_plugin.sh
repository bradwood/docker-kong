#!/bin/bash

# sets up a basic kong instance
# uses httpie rather than wget or curl

#Restart the Mock Server -- this tells it to reload all mapping files.

echo Resetting Mock Server mappings -- needed to have Wiremock re-read the files in the mappings mountpoint...
echo
http POST http://wiremock:8080/__admin/mappings/reset




# CREATE A KONG API

#delete if it was there before
echo Deleting the old Mobile API from Kong...
echo

http DELETE kong:8001/apis/mobile_api_v1.0

# set up a mobile API
# this requires an API name, an upstream URL and at least one of request_path or request_host (wildcards supported)
# we should probably use both and then we can use DNS later to move things around
# NOte, there are some precedence issues in using both of these request_ params at the same time
# see https://github.com/Mashape/kong/issues/1056

echo Creating a Mobile API in Kong
echo


http POST kong:8001/apis \
	name=mobile_api_v1.0 \
	upstream_url=http://wiremock:8080/ \
	request_path=/api/mobile/v1.0 \
	strip_request_path=true

echo Installing SSH Plugin and loading certificates...
echo

http POST kong:8001/apis/mobile_api_v1.0/plugins \
	name=ssl \
	config.cert=@./server.crt \
	config.key=@./server.key \
	config.only_https=true


echo Installing the API key plugin
echo

http POST kong:8001/apis/mobile_api_v1.0/plugins \
	name=key-auth \
	config.key_names=apikey \
	config.hide_credentials=false

echo Deleting the previous Consumer object \(if it exists\)
echo

http DELETE kong:8001/consumers/someusername


echo Creating a Consumer Object in Kong to associate an API key to
echo

http POST kong:8001/consumers \
	username=someusername \
	custom_id=somecustomConsumerID 

echo Creating an API key for the consumer
echo

# need to pass in an empty JSON doc to make this work
APIKEY=$(echo '{}' | http POST kong:8001/consumers/someusername/key-auth \
	Content-Type:application/json | jq '.key' | sed 's/"//g' )

echo Received API key $APIKEY ...
echo


echo Now testing the API through Kong...
echo Firstly without the API Key...

http --verify=no --print HBhb GET https://kong:8443/api/mobile/v1.0/hello Host:api.host.com

echo And now with the API Key \($APIKEY\) as a header
echo

http --verify=no --print HBhb GET https://kong:8443/api/mobile/v1.0/hello Host:api.host.com apikey:$APIKEY
