#!/bin/bash

test=`find -name '*.php' -exec /opt/php-7.0.30/sapi/cli/php -l {} \;|grep -v "No syntax errors detected in"`

if [ -z "$test" ]
then
        echo "No errors detected in php files"
else
        echo "$test"
fi
