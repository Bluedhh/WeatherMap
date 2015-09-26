use weather;
select @rownum := @rownum + 1 Rank
     , Name
     , Latest
     , Readings
     , AvgTemp
     , MaxTemp
     , MinTemp
     , `HI>90%`
     , `HI>80%`
     , `T<40%`
     , AvgHumid
     , AvgDP
     , `H>69%`
FROM (select @rownum := 0) as r
   , (Select Xref.Name
     , Date(max(ol.When)) Latest
     , count(*) Readings
     , Round(Avg(Temperature),1) AvgTemp
     , max(Temperature) MaxTemp
     , min(Temperature) MinTemp
     , coalesce(Round((ReallyHotDays / count(*))*100,1),0) `HI>90%`
     , coalesce(Round((HotDays / count(*))*100,1),0) `HI>80%`
     , coalesce(Round((ColdDays / count(*))*100,1),0) `T<40%`
     , Round(Avg(Humidity),1) AvgHumid
     , Round(Avg(DewPoint),1) AvgDP
     , coalesce(Round((HumidDays / count(*))*100,1),0) `H>69%`
  from Log as ol
  join Xref
    on Xref.Station = ol.Station
  join (SELECT @rownum := 0) r
  left join (select Station
             , count(*) HumidDays
          from Log il
         where DewPoint > 69
           and hour(il.When) = 14
           and month(il.When) not between 5 AND 10
         group by Station) as sd
    on sd.Station = ol.Station
  left join (select Station
             , count(*) ReallyHotDays
          from vLog il
         where HeatIndex between 90 and 130
           and hour(il.When) = 14
           and month(il.When) not between 5 AND 10
         group by Station) as rhd
    on rhd.Station = ol.Station
  left join (select Station
             , count(*) HotDays
          from vLog il
         where HeatIndex between 80 and 130
           and hour(il.When) = 14
           and month(il.When) not between 5 AND 10
         group by Station) as hd
    on hd.Station = ol.Station
  left join (select Station
             , count(*) ColdDays
          from Log il
         where Temperature between -40 and 40
           and hour(il.When) = 14
           and month(il.When) not between 5 AND 10
         group by Station) as cd
    on cd.Station = ol.Station
 where Temperature between -40 and 130
   and hour(ol.When) = 14
   and month(ol.When) not between 5 AND 10
 group by Xref.Name) as x
 order by `HI>90%` + `T<40%`+ `H>69%`
;
