#!/bin/bash

# The unsecure authentication API needs to be throttled to guard against Denial of Service
# attacks as mandated in the OAUTH2 specification. See https://tools.ietf.org/html/rfc6749#section-10.10

# I have not applied throttling to any other APIs at this time, but this one is a minimum to
# guard against brute force password attacks. Other APIs can be throttled as needed.

# load variable names
. api_config_variables

echo Installing Request Throttling Plugin for Authentication API
echo
# See https://getkong.org/plugins/rate-limiting/ for other options.
echo
http POST kong:8001/apis/$AUTHENTICATE_API_NAME/plugins \
	name=rate-limiting \
	config.minute=$AUTHENTICATE_API_PER_MIN_RATE_LIMIT # no more than x requests per minute
