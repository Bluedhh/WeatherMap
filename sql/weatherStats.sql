use weather;
select Xref.Name
     , Date(max(ol.When)) Latest
     , count(*) Readings
     , Round(Avg(Temperature),1) AvgTemp
     , max(Temperature) MaxTemp
     , min(Temperature) MinTemp
     , Round((HotDays / count(*))*100,1) HotPct
     , Round((ColdDays / count(*))*100,1) ColdPct
     , Round(Avg(Humidity),1) AvgHumid
     , max(Humidity) MaxHumid
     , min(Humidity) MinHumid
  from Log as ol
     , Xref
     , (select Station
             , count(*) HotDays
          from Log il
         where Temperature between 80 and 130
         group by Station) as hd
     , (select Station
             , count(*) ColdDays
          from Log il
         where Temperature between -40 and 40
         group by Station) as cd
 where Xref.Station = ol.Station
   and hd.Station = ol.Station
   and cd.Station = ol.Station
   and Temperature between -40 and 130
 group by Xref.Name
 order by 4 desc;
