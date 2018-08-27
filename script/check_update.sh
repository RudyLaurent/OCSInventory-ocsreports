echo "<h2>Existing tests on updates files</h2>"

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

cat_and_rm_mysql_err #Print error

update_files=`find files/update/ -name "*.sql"|sort`

for file in $update_files
do
	echo "<b>$file : </b>"
	mysql --login-path=jenkins -D ocs_check_SQL_jenkins --force < $file 2>>$error
	cat_and_rm_mysql_err
	echo "<br/>"
done

rm_err
