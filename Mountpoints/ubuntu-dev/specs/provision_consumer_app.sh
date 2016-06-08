#!/bin/bash

# load variable names
. api_config_variables

# This creates the consumer objects in kong, each of which must be created for an app that connects
# to our API

# empty out the provision key file
cp /dev/null $CLIENT_CREDENTIALS_FILE


echo Deleting previous Consumer objects \(if they exist\)...
echo

for i in "${!CONSUMER_PREFIXES[@]}"; do
	# the next 2 lines is some bash trickery to construct a variable name from a variable itself.
    CONSUMER_NAME=\$${CONSUMER_PREFIXES[$i]}_CONSUMER_NAME
    eval CONSUMER=$CONSUMER_NAME
    echo deleting consumer $CONSUMER ...
	http DELETE kong:8001/consumers/$CONSUMER
done


echo Creating Consumer objects...
echo

for i in "${!CONSUMER_PREFIXES[@]}"; do

    CONSUMER_NAME=\$${CONSUMER_PREFIXES[$i]}_CONSUMER_NAME
    eval CONSUMER=$CONSUMER_NAME

    CONSUMER_CUSTOM_ID=\$${CONSUMER_PREFIXES[$i]}_CONSUMER_CUSTOM_ID
    eval CUSTOM_ID=$CONSUMER_CUSTOM_ID

    echo creating consumer $CONSUMER ...
	http POST kong:8001/consumers \
		username=$CONSUMER \
		custom_id=$CUSTOM_ID
done

echo Now creating an OAUTH Application \(ie, a Client app record\) for each consumer.
echo We will create the client_id and client_secret for each consumer at this point.
echo These private credentials must be securely provided to the Client Application
echo Owner\/Developer as they will be needed to authenticate their app against our API...

for i in "${!CONSUMER_PREFIXES[@]}"; do

    CONSUMER_NAME=\$${CONSUMER_PREFIXES[$i]}_CONSUMER_NAME
    eval CONSUMER=$CONSUMER_NAME

    CONSUMER_OAUTH_APP_NAME=\$${CONSUMER_PREFIXES[$i]}_CONSUMER_OAUTH_APP_NAME
    eval OAUTH_APP_NAME=$CONSUMER_OAUTH_APP_NAME

	echo Creating OAUTH App and Credentials for $CONSUMER
	echo OAUTH Application Name: $OAUTH_APP_NAME
    echo
	http POST kong:8001/consumers/$CONSUMER/oauth2 \
		name=$(urlencode $OAUTH_APP_NAME) \
		redirect_uri=http://wiremock:8080/oauth_redirect_url
		# IMPORTANT -- the above Redirect URI is mandated by OAUTH2 Spec RFC6749
		# However, I do not think our implementation will need to use it
		# at least for Mobile SDK-based apps, and possibly RESTful apps too.
		# However, if needed, it must be specified by the client app owner.
		# For now, I think we can ignore it.
		# -- Brad
		# From the RFC:
		#   After completing its interaction with the resource owner, the
		#   authorization server directs the resource owner's user-agent back to
		#   the client.  The authorization server redirects the user-agent to the
		#   client's redirection endpoint previously established with the
		#   authorization server during the client registration process or when
		#   making the authorization request.

done

echo Now extracting the client_id and client_secret for each OAUTH Application...

for i in "${!CONSUMER_PREFIXES[@]}"; do

	CONSUMER_NAME=\$${CONSUMER_PREFIXES[$i]}_CONSUMER_NAME
    eval CONSUMER=$CONSUMER_NAME

    # get the Consumer JSON document from Kong and then use
    # jq - a JSON parser to extract the field required
    # then write them to a file for later use.
	echo getting client credentials for $CONSUMER ...
	JSON=$( http GET kong:8001/consumers/$CONSUMER/oauth2 )
	CLIENT_ID=$(echo $JSON| jq '.data[0].client_id' -r)
	echo Got client_id: $CLIENT_ID
	CLIENT_SECRET=$(echo $JSON| jq '.data[0].client_secret' -r)
	echo Got client_secret: $CLIENT_SECRET

	echo ${CONSUMER_PREFIXES[$i]}_CLIENT_ID\=$CLIENT_ID >> $CLIENT_CREDENTIALS_FILE
	echo ${CONSUMER_PREFIXES[$i]}_CLIENT_SECRET\=$CLIENT_SECRET >> $CLIENT_CREDENTIALS_FILE
done

