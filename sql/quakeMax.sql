use earthquakes;
select FROM_UNIXTIME(time/1000) as `When`, place, mag, lon, lat, depth from earthquake oo where concat(date(FROM_UNIXTIME(time/1000)),mag) = (select max(concat(date(FROM_UNIXTIME(time/1000)),mag)) from earthquake ii where date(FROM_UNIXTIME(ii.time/1000)) = date(FROM_UNIXTIME(oo.time/1000))) order by 1;
