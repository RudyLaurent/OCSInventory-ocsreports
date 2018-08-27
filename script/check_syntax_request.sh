#!/bin/bash

error="script/mysql.err"

#Remove file if exists
rm_err (){
	if [ -f $error ] ; then
		rm $error
	fi
}

#Function to print the error, remove the file and recreate to have an empty file
cat_and_rm_mysql_err (){
	cat $error
	rm_err
	touch $error
}

bash script/mysql_database_test.sh #script which drop if exists in database the test database ocs, and re-create this one with ocs base (more details in script/mysql_database_test.sh)

#Variable to test if they are syntax errors
finderror=0
if [[ $(cat $error) ]]
then
	finderror=1
fi

cat_and_rm_mysql_err #Print error

#This will check the SQL syntax of the last update files
#Write the GUI_VERSION into a text file
gui_version=`mysql --login-path=jenkins -D ocs_check_SQL_jenkins -e "select TVALUE from config where NAME='GUI_VERSION'"|grep -e "[0-9]"` # version of update
last_update=`find files/update/ -type f -printf "%f\n" -name "*.sql"|sort|sed '$!d'|sed 's/\.sql//'` # number of the last update commit

#Test if we found a gui_version
if [ -z $gui_version ]
then
	echo "ERROR GUI_VERSION NOT ACCESSIBLE IN \`config\` table"
	exit 1
else
	echo "<br/>" #for the report
	for file in  `find files/update/ -name "*.sql"|sort|seq -f "files/update/%g.sql" $(($gui_version+1)) $last_update` #We make the check on updates files
   	do
               	echo "<b>$file errors : </b>" #for the report
               	mysql --login-path=jenkins -D ocs_check_SQL_jenkins --force < $file 2>>$error  #connect to mysql with the test database and we import the update code

		#if the contents of error file is not empty
		if [[ $(cat $error) ]]
		then
			finderror=1 #we found an error
		fi

		cat_and_rm_mysql_err
		echo "<br/>"
	done
fi

#if there is no error in recent updates files , we will check all updates files
if (( $finderror == 0)); then
	echo "<h3>No syntax errors</h3>"
	bash script/check_update.sh #script to check
fi

rm_err
