#!/bin/bash
 
#Group of all requests/create in php/sql files

#SELECT requests in php files
select_request=`grep -o -r --include=*.php -e 'select .* from [\`A-Za-z\_\-\`\,0-9]*' -e 'SELECT .* FROM [\`A-Za-z\_\-\`\,0-9]*'|sed -e 's/\`//g'|awk '{print $NF}'|sort|uniq|sed -e 's/,/\n/g'|grep -v 'from\|FROM\|the\|%s\|table'`
#[\`A-Za-z\_\-\*\ \,\.0-9]

#UPDATE requests in php/sql files
update_request=`grep -o -r --include=*.{php,sql} -e 'UPDATE [\`A-Za-z\_\-\0-9]* SET' -e 'update [\`A-Za-z\_\-\`0-9]* set'|sed -e 's/\`//g'|awk '{print $2}' |sort |uniq|grep -v '%s'`

#CREATE TABLE in files/updates/*.sql
#create_table_update=`find files/update/ -name "*.sql" -exec cat {} \; |grep -e "CREATE TABLE" -e "create table" |sed -e 's/\`//g'|sed -e 's/IF NOT EXISTS//g'|awk '{print $3}'|sort |uniq`

#ALTER TABLE in sql files (start with ALTER TABLE)
alter_table=`grep -o -r --include=*.sql -e '^ALTER TABLE [\`A-Za-z\_\-\`0-9]*' -e '^alter table [\`A-Za-z\_\-\`0-9]*' |sed -e 's/\`//g'|awk '{print $3}'|sort |uniq`

#INSERT INTO in sql files (start with INSERT INTO)
insert_into_sql=`grep -o -r --include=*.sql -e '^INSERT INTO [\`A-Za-z\_\-\`0-9]*' -e '^insert into [\`A-Za-z\_\-\`0-9]*' |sed -e 's/\`//g'|awk '{print $3}'|sort |uniq`

#INSERT INTO in php files (different than sql files)
insert_into_php=`grep -o -r --include=*.php -e 'INSERT INTO [\`A-Za-z\_\-\`0-9]*' -e 'insert into [\`A-Za-z\_\-\`0-9]*' |sed -e 's/\`//g'|awk '{print $3}'|sort |uniq|grep -v '%s'`

#DROP

#DELETE
delete_request=`grep -o -r --include=*.{php,sql} -e 'DELETE FROM [\`A-Za-z\_\-\`0-9]*' -e 'delete from [\`A-Za-z\_\-\`0-9]*'|sed -e 's/\`//g'|awk '{print $3}' |sort |uniq|grep -v '%s'`


#CREATE TABLE in files/ocsbase.sql and files/ocsbase_new.sql (all the tables)
create_table=`grep -o -r --include=*.sql -e 'CREATE TABLE [\`A-Za-z\_\-\`0-9\ ]*' -e 'create table [\`A-Za-z\_\-\`0-9\ ]*'|sed -e 's/\`//g'|sed -e 's/IF NOT EXISTS//g'|awk '{print $3}'|sort|uniq`

#! -path "*/files/update/*"#

#Check if table used in sql requests is in database
#@param $1		-Tables used in request
#@param $2		-String to display in report
#@param $3		-Type of files to make the search
check_table_exist (){
	echo "<h3>$2</h3>"
	for table in $1
	do
		if ! grep -q -w $table <<< $create_table #if we found table used in request in database
		then
			echo "<b>sql > $table : not existing</b><br/>"
	 		if [[ "$4" = "php" ]]; then
				result=`grep -w -rn --include=*.php "$table"|grep "$3"` #echo file:line-number:line where we found the error
			elif [[ "$4" = "sql" ]]; then
				result=`grep -w -rn --include=*.sql "$table"|grep "$3"` #echo file:line-number:line where we found the error
			else
				result=`grep -w -rn --include=*.{php,sql} "$table"|grep "$3"` #echo file:line-number:line where we found the error
			fi
			echo "$result"
		fi
	done
}

#check_table_update_exist (){
#	for table in $1
#	do
#		if grep -q $table <<< $create_table
#		then
#			echo "sql > CREATE $table : exist in files/update"
#		fi
#	done
#}

#check_table_update_exist "$create_table_update"
check_table_exist "$select_request" "Check if tables used in SELECT request in php files are in database" "SELECT [\`A-Za-z\_\-\*\ \,\.0-9]* FROM [\`A-Za-z\_\-\`\,0-9]*\|select [\`A-Za-z\_\-\*\ \,\.0-9]* from [\`A-Za-z\_\-\`\,0-9]*" "php"
check_table_exist "$update_request" "Check if tables used in UPDATE request in php/sql files are in database" "UPDATE [\`A-Za-z\_\-\`0-9]* SET\|update [\`A-Za-z\_\-\`0-9]* set" "php,sql"
check_table_exist "$alter_table" "Check if tables used in ALTER TABLE request in sql files are in database" "ALTER TABLE [\`A-Za-z\_\-\`0-9]*\|alter table [\`A-Za-z\_\-\`0-9]*" "sql"
check_table_exist "$insert_into_sql" "Check if tables used in INSERT INTO request in sql files are in database" "INSERT INTO [\`A-Za-z\_\-\`0-9]*\|insert into [\`A-Za-z\_\-\`0-9]*" "sql"
check_table_exist "$insert_into_php" "Check if tables used in INSERT INTO request in php files are in database" "INSERT INTO [\`A-Za-z\_\-\`0-9]*\|insert into [\`A-Za-z\_\-\`0-9]*" "php"
check_table_exist "$delete_request" "Check if tables used in DELETE request in php/sql files are in database" "DELETE FROM [\`A-Za-z\_\-\`0-9]*\|delete from [\`A-Za-z\_\-\`0-9]*" "php,sql"
