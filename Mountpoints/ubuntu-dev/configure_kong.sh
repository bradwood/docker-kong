#!/bin/bash

# sets up a basic kong instance
# uses httpie rather than wget or curl

# create an API in kong
# this requires an API name, an upstream URL and at least one of request_path or request host (wildcards supported)
# for bidco we should use both and then we can use DNS later to move things around


#delete if it was there before

http DELETE kong:8001/apis/mobile_api

http POST kong:8001/apis \
	name=mobile_api \
	upstream_url=http://wiremock:8080/ \
	request_host=api.host.com
	

