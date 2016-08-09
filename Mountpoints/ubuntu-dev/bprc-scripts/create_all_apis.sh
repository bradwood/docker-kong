#!/usr/bin/env bash
# Requires https://github.com/bradwood/BPRC v0.6.1 or higher.
echo Truncated logfile...
cp /dev/null bprc.log

for f in $(ls -1t create*api.yml)
do
	cat $f | bprc \
	--log-level=debug \
	--output-format=raw-all \
	--skip-http-errors > /dev/null
done

echo Quick grep of the output files for any HTTP errors
grep ^HTTP create_*output
