#!/bin/bash

# load variable names
. api_config_variables

# empty out the provision key file
cp /dev/null $PROVISION_KEY_FILE

echo Installing OAUTH2 Plugin and enabling CLIENT Credentials Grant for Signup APIs...

# build up a scope string for the Auth API of all the scopes we will accept on it.
#format is comma-separated, but without spaces.
for i in "${!SECURE_API_REQUEST_PATHS[@]}"; do
	SCOPES+="${SECURE_API_REQUEST_PATHS[$i]}/$API_VERSION,"
done

# need to strip off the trailing comma now
SCOPES=$(echo $SCOPES | sed -e 's/,$//')
echo scopes $SCOPES
echo
echo installing OAUTH2 plugin for $SIGNUP_API_NAME ... \(client credentials grant\)

SIGNUP_API_PROVISION_KEY=$( http POST kong:8001/apis/$SIGNUP_API_NAME/plugins \
	name="oauth2" \
	config.enable_authorization_code=false \
	config.enable_password_grant=false \
	config.enable_client_credentials=true \
	config.mandatory_scope=true \
	config.scopes="$SCOPES" \
	config.token_expiration=$OAUTH_TOKEN_EXPIRATION \
	| jq '.config.provision_key' -r )

echo Provision key for $SIGNUP_API_NAME obtained \( $SIGNUP_API_PROVISION_KEY \)
	echo ${SIGNUP_API_NAME}_KEY\=$SIGNUP_API_PROVISION_KEY >> $PROVISION_KEY_FILE.tmp


echo
echo

# this loads the oauth2 plugin into each Secure API and then writes the provision key
# provided by each API into a file for later usage.

echo Installing OAUTH2 Plugin and enabling RESOURCE OWNER Credentials Grant for Secure APIs...

for i in "${!SECURE_API_NAMES[@]}"; do
	echo installing OAUTH2 plugin for ${SECURE_API_NAMES[$i]} ... \(resource owner credentials grant\)
	PROVISION_KEY=$( http POST kong:8001/apis/${SECURE_API_NAMES[$i]}/plugins \
		name="oauth2" \
		config.enable_authorization_code=false \
		config.enable_password_grant=true \
		config.scopes="${SECURE_API_REQUEST_PATHS[0]}/$API_VERSION" \
		config.mandatory_scope=true \
		config.token_expiration=$OAUTH_TOKEN_EXPIRATION \
		| jq '.config.provision_key' -r )
	echo Provision key for ${SECURE_API_NAMES[$i]} obtained \( $PROVISION_KEY \)
	echo ${SECURE_API_NAMES[$i]}_KEY\=$PROVISION_KEY >> $PROVISION_KEY_FILE.tmp
done

#clean up provision_key file
cat $PROVISION_KEY_FILE.tmp  | sed -e 's/\./\_/g;s/\-/\_/g' >$PROVISION_KEY_FILE
rm $PROVISION_KEY_FILE.tmp
