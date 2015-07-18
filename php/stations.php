<?php
    $username = "jack"; 
    $password = "246*8531";   
    $host = "localhost";
    $database="weather";
    
    $server = mysql_connect($host, $username, $password);
    $connection = mysql_select_db($database, $server);

    $rankBy = $_GET["rankBy"];

    $myquery = "
select @rownum := @rownum + 1 Rank
     , Station
     , Name
     , Display
     , Latitude
     , Longitude
     , Elevation
     , Latest
     , Readings
     , AvgHI
     , AvgTemp
     , MaxTemp
     , MinTemp
     , NightlyAvg
     , AvgTemp - NightlyAvg DailyDiff
     , `Hot%` as HotPct
     , `Warm%` as WarmPct
     , `Cold%` as ColdPct
     , `Cool%` as CoolPct
     , `Nice%` as NicePct
     , `Nice%` + `Cool%` + `Warm%` as DecentPct
     , AvgHumid
     , AvgDP
     , `Humid%` as HumidPct
     , `Rainy%` as RainyPct
FROM (select @rownum := 0) as r
   , (Select Xref.Station
     , Xref.Name
     , Xref.Display
     , Xref.Latitude
     , Xref.Longitude
     , Xref.Elevation
     , Date(max(ol.When)) Latest
     , count(*) Readings
     , Round(Avg(HeatIndex),1) AvgHI
     , Round(Avg(Temperature),1) AvgTemp
     , max(Temperature) MaxTemp
     , min(Temperature) MinTemp
     , NightlyAvg
     , coalesce(Round((ReallyHotDays / count(*))*100,1),0) `Hot%`
     , coalesce(Round((HotDays / count(*))*100,1),0) `Warm%`
     , coalesce(Round((ColdDays / count(*))*100,1),0) `Cold%`
     , coalesce(Round((CoolDays / count(*))*100,1),0) `Cool%`
     , coalesce(Round((NiceDays / count(*))*100,1),0) `Nice%`
     , Round(Avg(Humidity),1) AvgHumid
     , Round(Avg(CalcDewPoint),1) AvgDP
     , coalesce(Round((HumidDays / count(*))*100,1),0) `Humid%`
     , coalesce(Round((RainyDays / count(*))*100,1),0) `Rainy%`
  from vLog as ol
  join Xref
    on Xref.Station = ol.Station
  join (SELECT @rownum := 0) r
  left join (select Station
             , count(Distinct Date(`When`)) RainyDays
          from vLog il
         where RainRate > 0
       --    and hour(il.When) = 14
           and date(il.When) >= '2012-01-01'
         group by Station) as rd
    on rd.Station = ol.Station
  left join (select Station
             , count(*) HumidDays
          from vLog il
         where CalcDewPoint > 69
           and hour(il.When) = 14
           and date(il.When) >= '2012-01-01'
         group by Station) as sd
    on sd.Station = ol.Station
  left join (select Station
             , count(*) ReallyHotDays
          from vLog il
         where HeatIndex between 90.1 and 130
           and hour(il.When) = 14
           and date(il.When) >= '2012-01-01'
         group by Station) as rhd
    on rhd.Station = ol.Station
  left join (select Station
             , count(*) HotDays
          from vLog il
         where HeatIndex between 80.1 and 90
           and hour(il.When) = 14
           and date(il.When) >= '2012-01-01'
         group by Station) as hd
    on hd.Station = ol.Station
  left join (select Station
             , count(*) ColdDays
          from vLog il
         where HeatIndex between -40 and 29.9
           and hour(il.When) = 14
           and date(il.When) >= '2012-01-01'
         group by Station) as cd
    on cd.Station = ol.Station
  left join (select Station
             , count(*) CoolDays
          from vLog il
         where HeatIndex between 30 and 49.9
           and hour(il.When) = 14
           and date(il.When) >= '2012-01-01'
         group by Station) as coold
    on coold.Station = ol.Station
  left join (select Station
             , count(*) NiceDays
          from vLog il
         where HeatIndex between 50 and 80
           and hour(il.When) = 14
           and date(il.When) >= '2012-01-01'
         group by Station) as nd
    on nd.Station = ol.Station
  left join (select Station
             , Round(avg(HeatIndex),1) NightlyAvg
          from vLog il
         where hour(il.When) = 2
           and date(il.When) >= '2012-01-01'
         group by Station) as na
    on na.Station = ol.Station
 where Temperature between -40 and 130
   and hour(ol.When) = 14
   and date(ol.When) >= '2012-01-01'
 group by Xref.Name) as x
 WHERE DATEDIFF(NOW(),Latest) < 30
 order by " . $rankBy . " desc;
";
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
