#!/bin/bash

#resets kong completely, ready for a fresh test.

# reset wiremock so it reloads all mappings and __files
./reset_wiremock.sh
read
#Create the APIs (deleting any old ones)
./create_apis.sh
read
#add SSL to APIS
./load_ssl_plugins.sh
read
#set up OAUTH plugins and save the provision keys for each
./load_oauth2_plugins_and_obtain_provision_keys.sh
read
#set up API ACLs
./configure_API_ACLs.sh
read
#create consumers and save client_ids and client_secrets
./provision_consumer_app.sh
read
#apply ACLs to consumers
./configure_consumer_ACLs.sh
read
#TODO: add API thottling...
