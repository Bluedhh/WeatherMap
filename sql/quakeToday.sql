use earthquakes;
select FROM_UNIXTIME(time/1000) as `When`
     , place
     , mag
     , lon
     , lat
     , depth from earthquake
 where date(FROM_UNIXTIME(time/1000)) = date(now())
 order by time;
