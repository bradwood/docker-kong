#!/bin/bash

# load variable names
. api_config_variables

# empty out the provision key file
cp /dev/null $PROVISION_KEY_FILE

# this loads the oauth2 plugin into each Secure API and then writes the provision key
# provided by each API into a file for later usage.

echo Installing OAUTH2 Plugin and enabling Resource Owner Credentials Grant for Secure APIs...

for i in "${!SECURE_API_NAMES[@]}"; do
	echo installing OAUTH2 plugin for ${SECURE_API_NAMES[$i]} ...
	PROVISION_KEY=$( http POST kong:8001/apis/${SECURE_API_NAMES[$i]}/plugins \
		name="oauth2" \
		config.enable_authorization_code=false \
		config.enable_password_grant=true \
		config.token_expiration=$OAUTH_TOKEN_EXPIRATION \
		| jq '.config.provision_key' -r )
	echo Provision key for ${SECURE_API_NAMES[$i]} obtained \( $PROVISION_KEY \)
	echo ${SECURE_API_NAMES[$i]}_KEY\=$PROVISION_KEY >> $PROVISION_KEY_FILE.tmp
done

#clean up provision_key file
cat $PROVISION_KEY_FILE.tmp  | sed -e 's/\./\_/g;s/\-/\_/g' >$PROVISION_KEY_FILE
rm $PROVISION_KEY_FILE.tmp
