#/!bin/bash

mysql --login-path=jenkins --force <<EOF 2>>script/mysql.err  # connect to mysql (EOF is used to enter multiple requests on mysql simultaneously on standard input, while EOF isn't read)
DROP DATABASE IF EXISTS ocs_check_SQL_jenkins; # drop the database test before creating it
CREATE DATABASE ocs_check_SQL_jenkins; # create empty database for test
USE ocs_check_SQL_jenkins; # switch on this database
source files/ocsbase.sql; # import of ocs base
EOF
