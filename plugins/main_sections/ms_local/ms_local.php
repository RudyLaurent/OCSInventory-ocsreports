<?php 
//====================================================================================
// OCS INVENTORY REPORTS
// Copyleft Pierre LEMMET 2005
// Web: http://www.ocsinventory-ng.org
//
// This code is open source and may be copied and modified as long as the source
// code is always made freely available.
// Please refer to the General Public Licence http://www.gnu.org/ or Licence.txt
//====================================================================================
//Modified on $Date: 2006-12-21 18:13:46 $$Author: plemmet $($Revision: 1.5 $)

$port = "80";
$server = "localhost";
$conSql = "SELECT * FROM config WHERE name IN('LOCAL_SERVER', 'LOCAL_PORT')";
$resSql = mysql_query( $conSql );

while( $valSql = mysql_fetch_array( $resSql ) ) {
	if( $valSql["NAME"] == "LOCAL_SERVER" )
		$server = $valSql["TVALUE"];
	if( $valSql["NAME"] == "LOCAL_PORT" )
		$port = $valSql["IVALUE"];	
}

if(is_uploaded_file($_FILES['userfile']['tmp_name'])) {
	
	if( getFileExtension($_FILES['userfile']['name']) != "ocs" ) {
		msg_error($l->g(559));
	}
	else {
		$fd = fopen($_FILES['userfile']['tmp_name'], "r");
		$contents = fread($fd, filesize ($_FILES['userfile']['tmp_name']));
		fclose($fd);

		$result = post_it($contents, "http://".$server."/ocsinventory", $port);
		
		if (isset($result["errno"])) {
			$errno = $result["errno"];
			$errstr = $result["errstr"];
			msg_error($l->g(344). $errno . " / " . $errstr);
		}else {
			if( ! strstr ( $result[0], "200") )
				msg_error($l->g(344). " " . $result[0]);
			else {
				msg_success($l->g(287)." OK");
			}
		}
	}
}
?>

<FORM ENCTYPE="multipart/form-data" METHOD="POST">
<br>
<table border=1 class= "Fenetre" WIDTH = '52%' ALIGN = 'Center' CELLPADDING='5'>
<th height=30px class="Fenetre" colspan=2>
	<b><?php echo $l->g(288)." (".$l->g(560).": http://".$server.":".$port.")"; ?></b>
</th>
	<tr bgcolor='#F2F2F2'><td><?php echo $l->g(137);?></td>
	    <td><INPUT NAME="userfile" size='80' TYPE="file"></td></tr>	
	<tr bgcolor='white'>
	    <td colspan=2 align=right><INPUT TYPE="submit" VALUE="<?php echo $l->g(13);?>"></td>
	</tr>
</table>
</FORM>
<?php 

function post_it($datastream, $url, $port) {
	
	$url = preg_replace("@^http://@i", "", $url);
	$host = substr($url, 0, strpos($url, "/"));
	$uri = strstr($url, "/");
	$reqbody = $datastream;
	
	$contentlength = strlen($reqbody);
	$reqheader =  "POST $uri HTTP/1.1\r\n".
	"Host: $host\n". "User-Agent: OCS_local_".GUI_VER."\r\n".
	"Content-type: application/x-compress\r\n".
	"Content-Length: $contentlength\r\n\r\n".
	"$reqbody\r\n";
	
	$socket = @fsockopen($host, $port, $errno, $errstr);
	
	if (!$socket) {
		$result["errno"] = $errno;
		$result["errstr"] = $errstr;
		return $result;
	}
	fputs($socket, $reqheader);
	
	while (!feof($socket)) {
		$result[] = fgets($socket, 4096);
	}
	
	fclose($socket);
	return $result;
}

function getFileExtension($str) { 
	$i = strrpos($str,"." );
	if (!$i) { return ""; }
	$l = strlen($str) - $i;
	$ext = substr($str,$i+1,$l);
	return $ext; 
} 
?>