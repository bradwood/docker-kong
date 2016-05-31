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

http DELETE kong:8001/apis/mobile_api

# set up a mobile API
# this requires an API name, an upstream URL and at least one of request_path or request_host (wildcards supported)
# we should probably use both and then we can use DNS later to move things around

echo Creating a Mobile API in Kong
echo


http POST kong:8001/apis \
	name=mobile_api \
	upstream_url=http://wiremock:8080/ \
	request_host=api.host.com


echo Now testing the API through Kong...
echo

http GET http://kong:8000/hello Host:api.host.com
