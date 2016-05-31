#!/bin/bash

# sets up a basic kong instance
# uses httpie rather than wget or curl

#Set up variables

API_NAME=mobile_api_v1.0
CONSUMER_NAME=some_consumer_name
CONSUMER_CUSTOM_ID=some_custom_consumer_id


#Restart the Mock Server -- this tells it to reload all mapping files.
echo
echo ------------------------------------------------------------------------------------------
echo
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

echo Installing SSL Plugin and loading certificat2es for $API_NAME API 
echo

http POST kong:8001/apis/$API_NAME/plugins \
	name=ssl \
	config.cert=@./server.crt \
	config.key=@./server.key \
	config.only_https=true

echo Installing oauth2 plugin for the $API_NAME API 
echo enable password grant flow
echo

PROVISION_KEY=$( http POST kong:8001/apis/$API_NAME/plugins \
	name="oauth2" \
	config.enable_authorization_code=false \
	config.enable_password_grant=true \
	2>/dev/null \
	| jq '.config.provision_key' -r )

echo Got provision_key $PROVISION_KEY
echo

echo Deleting the previous Consumer object \(if it exists\)
echo

http DELETE kong:8001/consumers/$CONSUMER_NAME


echo Creating a Consumer Object $CONSUMER_NAME 
echo

http POST kong:8001/consumers \
	username=$CONSUMER_NAME \
	custom_id=$CONSUMER_CUSTOM_ID 

echo Now Creating an OAUTH Application for $CONSUMER_NAME \(ie, a Credential associated to a Consumer \)
echo
echo Note, we are not specifying a client_id, nor a client_secret. We will let Kong create
echo these for us so they can be supplied to the client app
echo

 http POST kong:8001/consumers/$CONSUMER_NAME/oauth2 \
	name="My OAUTH2 Application Name" \
	redirect_uri=http://wiremock:8080/oauth_redirect_url

OAUTH_CLIENT_ID=$( http GET kong:8001/consumers/$CONSUMER_NAME/oauth2 \
	name="My OAUTH2 Application Name" \
	redirect_uri=http://wiremock:8080/oauth_redirect_url \
	| jq '.data[0].client_id' -r )

echo got client_id=$OAUTH_CLIENT_ID
echo

OAUTH_CLIENT_SECRET=$( http GET kong:8001/consumers/$CONSUMER_NAME/oauth2 \
	name="My OAUTH2 Application Name" \
	redirect_uri=http://wiremock:8080/oauth_redirect_url \
	| jq '.data[0].client_secret' -r )

echo got client_secret=$OAUTH_CLIENT_SECRET ...
echo

echo Now testing the API...


echo Now requesting a token
echo

ACCESS_TOKEN=$( http --form --verify=no POST https://kong:8443/api/mobile/v1.0/oauth2/token \
	Host:api.host.com \
	provision_key=$PROVISION_KEY \
	grant_type=password \
	authenticated_userid=id \
	client_id=$OAUTH_CLIENT_ID \
	client_secret=$OAUTH_CLIENT_SECRET \
	username=username \
	password=password \
	2>/dev/null \
	| jq '.access_token' -r ) 

echo got access_token=$ACCESS_TOKEN ...
echo

echo calling the API now with the access_token....
echo

http --verify=no --print HBhb GET https://kong:8443/api/mobile/v1.0/hello \
	Host:api.host.com \
	Authorization:"Bearer $ACCESS_TOKEN" \
	2>/dev/null

echo calling the API now with a broken access_token....
echo

http --verify=no --print HBhb GET https://kong:8443/api/mobile/v1.0/hello \
	Host:api.host.com \
	Authorization:"Bearer x$ACCESS_TOKEN" \
	2>/dev/null 