#!/bin/bash

# load variable names
. api_config_variables

# Setting up group assignments for each Consumer
echo Creating Consumer ACLs...
echo

for i in "${!CONSUMER_PREFIXES[@]}"; do

	CONSUMER_NAME=\$${CONSUMER_PREFIXES[$i]}_CONSUMER_NAME
    eval CONSUMER=$CONSUMER_NAME

    CONSUMER_ACL_GROUPS=\$${CONSUMER_PREFIXES[$i]}_CONSUMER_ACL_GROUPS
    eval ACL_GROUPS=$CONSUMER_ACL_GROUPS


	echo Setting ACL group\(s\) for $CONSUMER ...
	echo groups:ACL_GROUPS
	http -v POST kong:8001/consumers/$CONSUMER/acls \
		group=$ACL_GROUPS

done

