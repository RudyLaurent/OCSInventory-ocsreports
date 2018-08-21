#!/bin/bash


test=`find -name '*.php' -exec /opt/php-5.4.24/sapi/cli/php -l {} \;|grep -v "No syntax errors detected in"`

if [ -z "$test" ]
then
	echo "No errors detected in php files"
else
	echo "$test"
fi
