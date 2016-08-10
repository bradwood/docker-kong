#!/usr/bin/env bash
# Requires https://github.com/bradwood/BPRC v0.6.8 or higher.
echo Truncating log and output files...
cp /dev/null bprc.log
cp /dev/null create_all_apis.output


for f in $(ls -1t create*api.yml)
do
	cat $f | bprc \
	--log-level=debug \
	--output-format=raw-response -v >> create_all_apis.output
done

echo Quick grep of the output files for any HTTP errors
grep ^HTTP create_all_apis.output
