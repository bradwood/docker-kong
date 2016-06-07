#!/bin/bash
#Restart the Mock Server -- this tells it to reload all mapping files.
echo
echo ------------------------------------------------------------------------------------------
echo
echo Resetting Mock Server mappings -- needed to have Wiremock re-read the files in the mappings mountpoint...
echo
http POST http://wiremock:8080/__admin/mappings/reset
