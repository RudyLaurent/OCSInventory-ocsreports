#!/bin/sh

#Remove file if exists
file="report.html"

if [ -f $file ] ; then
	rm $file
fi

touch $file

#Create file
echo '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" >
    <head>
      <meta content="text/html; charset=utf-8" />
      <link href="style_report.css" rel="stylesheet" type"text/css">
    </head>
    <body>
       <h1>Result of PHP Lint analysis</h1>
        <h2>lint 5.4 :</h2>
         <p>' >> $file

bash script/lint-5.4.sh >> $file

echo '   </p>
        <h2>lint 5.6 :</h2>
	 <p>' >> $file

bash script/lint-5.6.sh >> $file

echo '   </p>
        <h2>lint 7.0 :</h2>
         <p>' >> $file

bash script/lint-7.0.sh >> $file

echo '   </p>
      <h1>Result of MySQL analysis</h1>
       <h2>SQL Requests :</h2>
	<p>' >> $file

bash script/check_table.sh >> $file

echo '  </p>
       <h2>Syntax analysis of SQL files :</h2>
        <p>' >> $file

bash script/check_syntax_request.sh >> $file

echo '  </p>
    </body>
</html>' >> $file

