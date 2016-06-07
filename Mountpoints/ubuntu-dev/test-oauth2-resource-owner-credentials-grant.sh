#!/bin/bash

# sets up a basic kong instance
# uses httpie rather than wget or curl

#Set up variables

API_NAME=mobile_api_v1.0
AUTHORIZE_API_NAME=authorize
CONSUMER_NAME=BootsPLC
CONSUMER_CUSTOM_ID=BOOT_012344


#Restart the Mock Server -- this tells it to reload all mapping files.
echo
echo ------------------------------------------------------------------------------------------
echo
echo Resetting Mock Server mappings -- needed to have Wiremock re-read the files in the mappings mountpoint...
echo
http POST http://wiremock:8080/__admin/mappings/reset


# CREATE A KONG API

#delete if it was there before
echo Deleting APIs $API_NAME API and $AUTHORIZE_API_NAME
echo

http DELETE kong:8001/apis/$API_NAME
http DELETE kong:8001/apis/$AUTHORIZE_API_NAME

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

# set up an authorisation API

echo Creating authorisation API $AUTHORIZE_API_NAME
echo


http POST kong:8001/apis \
	name=$AUTHORIZE_API_NAME \
	upstream_url=https://wiremock:8081/ \
	request_path=/oauth2/token \

echo Installing SSL Plugin and loading certificates for $API_NAME API
echo

http POST kong:8001/apis/$API_NAME/plugins \
	name=ssl \
	config.cert=@./server.crt \
	config.key=@./server.key \
	config.only_https=true

echo Installing SSL Plugin and loading certificates for $AUTHORIZE_API_NAME API
echo

echo
http POST kong:8001/apis/$AUTHORIZE_API_NAME/plugins \
	name=ssl \
	config.cert=@./server.crt \
	config.key=@./server.key \
	config.only_https=true

echo Installing oauth2 plugin for the $API_NAME API
echo enable resource owner password grant flow
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
	name="Boots.com Mobile App v2 - $CONSUMER_NAME" \
	redirect_uri=http://wiremock:8080/oauth_redirect_url

OAUTH_CLIENT_ID=$( http GET kong:8001/consumers/$CONSUMER_NAME/oauth2 \
	| jq '.data[0].client_id' -r )

echo Now getting the Client_ID for this client application of $CONSUMER_NAME
echo got client_id=$OAUTH_CLIENT_ID
echo

OAUTH_CLIENT_SECRET=$( http GET kong:8001/consumers/$CONSUMER_NAME/oauth2 \
	| jq '.data[0].client_secret' -r )

echo Now getting the Client_Secret for this client application of $CONSUMER_NAME
echo got client_secret=$OAUTH_CLIENT_SECRET ...
echo

echo Both the clienth_id and the client_secret must be used by $CONSUMER_NAME in their app in order for our APIs
echo to respond. We trust the client to keep these client credentials secret.
echo
echo Now testing the API...


echo Now requesting a token
echo

ACCESS_TOKEN=$( curl -k https://kong:8443/oauth2/token \
    --data "client_id=$OAUTH_CLIENT_ID" \
    --data "client_secret=$OAUTH_CLIENT_SECRET" \
    --data "provision_key=$PROVISION_KEY" \
    --data "authenticated_userid=pepe" \
    --data "username=asdsad" \
    --data "grant_type=password" \
    --data "password=dasda" \
	| jq '.access_token' -r )


echo got access_token=$ACCESS_TOKEN ...
echo

echo calling the API now with the access_token....
echo

http --verify=no --print HBhb GET https://kong:8443/api/mobile/v1.0/hello \
	Authorization:"Bearer $ACCESS_TOKEN" \
	2>/dev/null

echo calling the API now with a broken access_token....
echo

http --verify=no --print HBhb GET https://kong:8443/api/mobile/v1.0/hello \
	Host:api.host.com \
	Authorization:"Bearer x$ACCESS_TOKEN" \
	2>/dev/null
