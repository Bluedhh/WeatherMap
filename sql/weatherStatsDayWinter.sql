use weather;
select @rownum := @rownum + 1 Rank
     , Name
     , Latest
     , Readings
     , AvgTemp
     , MaxTemp
     , MinTemp
     , `Hot%`
     , `Warm%`
     , `Cold%`
     , `Cool%`
     , `Nice%`
     , AvgHumid
     , AvgDP
     , `Humid%`
     , `Rainy%`
FROM (select @rownum := 0) as r
   , (Select Xref.Name
     , Date(max(ol.When)) Latest
     , count(*) Readings
     , Round(Avg(Temperature),1) AvgTemp
     , max(Temperature) MaxTemp
     , min(Temperature) MinTemp
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
           and ((month(il.When) * 100) + day(il.When) < 0501 or
                (month(il.When) * 100) + day(il.When) > 1030)
         group by Station) as rd
    on rd.Station = ol.Station
  left join (select Station
             , count(*) HumidDays
          from vLog il
         where CalcDewPoint > 69
           and hour(il.When) = 14
           and date(il.When) >= '2012-01-01'
           and ((month(il.When) * 100) + day(il.When) < 0501 or
                (month(il.When) * 100) + day(il.When) > 1030)
         group by Station) as sd
    on sd.Station = ol.Station
  left join (select Station
             , count(*) ReallyHotDays
          from vLog il
         where HeatIndex between 90 and 130
           and hour(il.When) = 14
           and date(il.When) >= '2012-01-01'
           and ((month(il.When) * 100) + day(il.When) < 0501 or
                (month(il.When) * 100) + day(il.When) > 1030)
         group by Station) as rhd
    on rhd.Station = ol.Station
  left join (select Station
             , count(*) HotDays
          from vLog il
         where HeatIndex between 80 and 90
           and hour(il.When) = 14
           and date(il.When) >= '2012-01-01'
           and ((month(il.When) * 100) + day(il.When) < 0501 or
                (month(il.When) * 100) + day(il.When) > 1030)
         group by Station) as hd
    on hd.Station = ol.Station
  left join (select Station
             , count(*) ColdDays
          from Log il
         where Temperature between -40 and 30
           and hour(il.When) = 14
           and date(il.When) >= '2012-01-01'
           and ((month(il.When) * 100) + day(il.When) < 0501 or
                (month(il.When) * 100) + day(il.When) > 1030)
         group by Station) as cd
    on cd.Station = ol.Station
  left join (select Station
             , count(*) CoolDays
          from Log il
         where Temperature between 30 and 50
           and hour(il.When) = 14
           and date(il.When) >= '2012-01-01'
           and ((month(il.When) * 100) + day(il.When) < 0501 or
                (month(il.When) * 100) + day(il.When) > 1030)
         group by Station) as coold
    on coold.Station = ol.Station
  left join (select Station
             , count(*) NiceDays
          from Log il
         where Temperature between 50 and 80
           and hour(il.When) = 14
           and date(il.When) >= '2012-01-01'
           and ((month(il.When) * 100) + day(il.When) < 0501 or
                (month(il.When) * 100) + day(il.When) > 1030)
         group by Station) as nd
    on nd.Station = ol.Station
 where Temperature between -40 and 130
   and hour(ol.When) = 14
   and date(ol.When) >= '2012-01-01'
   and ((month(ol.When) * 100) + day(ol.When) < 0501 or
        (month(ol.When) * 100) + day(ol.When) > 1030)
 group by Xref.Name) as x
 order by `Nice%` desc, `Humid%` asc
;
