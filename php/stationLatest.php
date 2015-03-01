<?php
    $username = "jack"; 
    $password = "246*8531";   
    $host = "localhost";
    $database="weather";
    
    $server = mysql_connect($host, $username, $password);
    $connection = mysql_select_db($database, $server);

    $station = $_GET["station"];

    $myquery = "
select * 
  FROM Log 
 where Station = '" . $station . "'
   and `When` = (Select max(`When`) 
                   from Log 
                  where Station = '" . $station . "'
                    and hour(`When`) = 14)";

    $query = mysql_query($myquery);
    
    if ( ! $query ) {
        echo mysql_error();
        die;
    }
    
    $data = array();
    
    for ($x = 0; $x < mysql_num_rows($query); $x++) {
        $data[] = mysql_fetch_assoc($query);
    }
    
    echo json_encode($data);     
     
    mysql_close($server);
?>
