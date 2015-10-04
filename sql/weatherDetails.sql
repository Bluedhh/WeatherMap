use weather;
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
   and Station = 'KNJFLEMI6'
   and hour(`When`) = 14) as high
,   
(select Date(ol.When) ReadingDate
     , Round(Temperature,1) NightTemp
     , Round(Humidity,1) NightHumid
  from Log as ol
 where Temperature between -40 and 130
   and Station = 'KNJFLEMI6'
   and hour(`When`) = 2) as low
 where high.ReadingDate = low.ReadingDate
 order by 1,2;

