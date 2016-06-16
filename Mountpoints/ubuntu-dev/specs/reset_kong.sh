#!/bin/bash

#resets kong completely, ready for a fresh test.

# reset wiremock so it reloads all mappings and __files
./reset_wiremock.sh

#Create the APIs (deleting any old ones)
./create_apis.sh

#add SSL to APIS
./load_ssl_plugins.sh

#set up OAUTH plugins and save the provision keys for each
./load_oauth2_plugins_and_obtain_provision_keys.sh

#set up API ACLs
./configure_API_ACLs.sh

#create consumers and save client_ids and client_secrets
./provision_consumer_app.sh

#apply ACLs to consumers
./configure_consumer_ACLs.sh

#set up Correlation IDs to track upstream calls when logging
./load_correlationid_plugins.sh

# add API thottling...
./throttle_authentication_API.sh

# TODO: Add IP address whitelisting for non-consumer secure APIs (e.g, merchant, admin, etc)
