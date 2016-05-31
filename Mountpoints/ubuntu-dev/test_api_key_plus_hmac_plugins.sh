#!/bin/bash

# sets up a basic kong instance
# uses httpie rather than wget or curl

#Set up variables

API_NAME=mobile_api_v1.0
CONSUMER_NAME=some_consumer_name
CONSUMER_CUSTOM_ID=some_custom_consumer_id


#Restart the Mock Server -- this tells it to reload all mapping files.
echo Resetting Mock Server mappings -- needed to have Wiremock re-read the files in the mappings mountpoint...
echo
http POST http://wiremock:8080/__admin/mappings/reset


# CREATE A KONG API

#delete if it was there before
echo Deleting the $API_NAME API 
echo

http DELETE kong:8001/apis/$API_NAME

# set up a mobile API
# this requires an API name, an upstream URL and at least one of request_path or request_host (wildcards supported)
# we should probably use both and then we can use DNS later to move things around
# NOte, there are some precedence issues in using both of these request_ params at the same time
# see https://github.com/Mashape/kong/issues/1056

echo Creating $API_NAME API 
echo


http POST kong:8001/apis \
	name=$API_NAME \
	upstream_url=http://wiremock:8080/ \
	request_path=/api/mobile/v1.0 \
	strip_request_path=true

echo Installing SSL Plugin and loading certificates for $API_NAME API 
echo

http POST kong:8001/apis/$API_NAME/plugins \
	name=ssl \
	config.cert=@./server.crt \
	config.key=@./server.key \
	config.only_https=true


echo Installing the API key plugin for $API_NAME API 
echo

http POST kong:8001/apis/$API_NAME/plugins \
	name=key-auth \
	config.key_names=apikey \
	config.hide_credentials=false

echo Installing the HMAC Authentication plugin for $API_NAME API
echo

http POST kong:8001/apis/$API_NAME/plugins \
	name=hmac-auth \
	config.hide_credentials=false \
	config.clock_skew=300


echo Deleting the previous Consumer object \(if it exists\)
echo

http DELETE kong:8001/consumers/$CONSUMER_NAME


echo Creating a Consumer Object $CONSUMER_NAME 
echo

http POST kong:8001/consumers \
	username=$CONSUMER_NAME \
	custom_id=$CONSUMER_CUSTOM_ID 

echo Creating an API key for the consumer $CONSUMER_NAME
echo

# need to pass in an empty JSON doc to make this work
APIKEY=$(echo '{}' | http POST kong:8001/consumers/$CONSUMER_NAME/key-auth \
	Content-Type:application/json | jq '.key' -r )

echo Received API key $APIKEY ...
echo

echo Creating an HMAC Credential for the consumer $CONSUMER_NAME
echo Credential username=bob - note one consumer can have many credentials

http POST kong:8001/consumers/$CONSUMER_NAME/hmac-auth \
	username=bob \
	secret=bobspassword

#See http://stackoverflow.com/questions/7285059/hmac-sha1-in-bash

function hash_hmac {
  digest="$1"
  data="$2"
  key="$3"
  shift 3
  echo -n "$data" | openssl dgst "-$digest" -hmac "$key" "$@"
}

# hex output by default
#hash_hmac "sha1" "value" "key"

# raw output by adding the "-binary" flag
#hash_hmac "sha1" "value" "key" -binary | base64

# other algos also work
#hash_hmac "md5"  "value" "key"

echo Now testing the API...

# create the date in RFC 1123 format 
DATE=$(date -u +%a,\ %d\ %b\ %Y\ %H:%M:%S\ GMT)
#create the signature first and make sure the output is binary, not hex.
SIGNATURE=$(hash_hmac "sha1" "date: $DATE" "bobspassword" -binary)
echo ...with HMAC and API Key credentials
echo

#now call the API with the correct Auth header
http --verify=no --print HBhb GET https://kong:8443/api/mobile/v1.0/hello \
	Host:api.host.com \
	apikey:$APIKEY \
	Date:"$DATE" \
	Authorization:hmac\ username=\"bob\",\ algorithm=\"hmac-sha1\",\ headers=\"date\",\ signature=\"$(echo $SIGNATURE | base64)\"

echo ...with wrong HMAC but correct API Key credentials
echo

http --verify=no --print HBhb GET https://kong:8443/api/mobile/v1.0/hello \
	Host:api.host.com \
	apikey:$APIKEY \
	Date:"$DATE" \
	Authorization:hmac\ username=\"bob\",\ algorithm=\"hmac-sha1\",\ headers=\"date\",\ signature=\"BRAD$(echo $SIGNATURE | base64)\"

echo ... with correct API Key but no HMAC credentials
echo 
http --verify=no --print HBhb GET https://kong:8443/api/mobile/v1.0/hello Host:api.host.com apikey:$APIKEY

echo ... with no API Key and no HMAC credentials
echo
http --verify=no --print HBhb GET https://kong:8443/api/mobile/v1.0/hello Host:api.host.com

echo
echo lets test the clock skew now.
echo calling the same successful call above 
echo

http --verify=no --print HBhb GET https://kong:8443/api/mobile/v1.0/hello \
	Host:api.host.com \
	apikey:$APIKEY \
	Date:"$DATE" \
	Authorization:hmac\ username=\"bob\",\ algorithm=\"hmac-sha1\",\ headers=\"date\",\ signature=\"$(echo $SIGNATURE | base64)\"

echo 
echo now sleeping for 301 secs...
echo
sleep 301
echo
echo calling the same successful call above AGAIN -- this should fail.  

http --verify=no --print HBhb GET https://kong:8443/api/mobile/v1.0/hello \
	Host:api.host.com \
	apikey:$APIKEY \
	Date:"$DATE" \
	Authorization:hmac\ username=\"bob\",\ algorithm=\"hmac-sha1\",\ headers=\"date\",\ signature=\"$(echo $SIGNATURE | base64)\"

