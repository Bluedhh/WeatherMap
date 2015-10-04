<?php
    $username = "jack"; 
    $password = "246*8531";   
    $host = "localhost";
    $database="weather";
    
    $server = mysql_connect($host, $username, $password);
    $connection = mysql_select_db($database, $server);

    $station = $_GET["station"];

    $myquery = "
select high.ReadingDate
     , high.DayTemp
     , high.DayHumid
     , low.NightTemp
     , low.NightHumid
  from
(select Date(ol.When) ReadingDate
     , Round(Temperature,1) DayTemp
     , Round(Humidity,1) DayHumid
  from Log as ol
 where Temperature between -40 and 130
   and Station = '" . $station . "'
   and hour(`When`) = 14) as high
,   
(select Date(ol.When) ReadingDate
     , Round(Temperature,1) NightTemp
     , Round(Humidity,1) NightHumid
  from Log as ol
 where Temperature between -40 and 130
   and Station = '" . $station . "'
   and hour(`When`) = 2) as low
 where high.ReadingDate = low.ReadingDate
 order by 1,2";

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
