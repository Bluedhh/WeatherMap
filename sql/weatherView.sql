use weather;
Create or Replace View vLog As 
(Select *
      , CASE WHEN (Temperature >= 80 AND Humidity >= 40) 
             THEN ROUND(-42.379 + 
                        (2.04901523*Temperature) + 
                        (10.14333127*Humidity) + 
                        (-0.22475541*Temperature*Humidity) + 
                        ((-6.83783*POW(10,-3)*(POW(Temperature,2)))) + 
                        ((-5.481717*POW(10,-2))*(POW(Humidity,2))) + 
                        ((1.22874*POW(10,-3))*POW(Temperature,2)*Humidity) + 
                        ((8.5282*POW(10,-4))*Temperature*POW(Humidity,2)) + 
                        ((-1.99*POW(10,-6))*POW(Temperature,2)*POW(Humidity,2)),1) 
             WHEN (Temperature Between 70 AND 79.99 AND Humidity <= 80) 
             THEN ROUND(0.363445176 + 
                        (0.988622465*Temperature) + 
                        (4.777114035*Humidity) + 
                        (-0.114037667*Temperature*Humidity) + 
                        (-0.000850208*POW(Temperature,2)) + 
                        (-0.020716198*POW(Humidity,2)) + 
                        (0.000687678*POW(Temperature,2)*Humidity) + 
                        (0.000274954*Temperature*POW(Humidity,2)),1) ELSE Temperature END as HeatIndex 
      , Round(243.04*(LN(Humidity/100)+
        ((17.625*Temperature)/(243.04+Temperature)))/(17.625-LN(Humidity/100)-
        ((17.625*Temperature)/(243.04+Temperature))),1) as CalcDewPoint
   From Log);

Create or Replace View vWinter As 
(Select vLog.Station
           , Name
           , round(avg(Temperature),1) AvgTemp
           , round(avg(CalcDewPoint),1) AvgDP
        from vLog
           , Xref
       where Xref.Station = vLog.Station
         and ((month(`When`) * 100) + day(`When`) < 0321 or
              (month(`When`) * 100) + day(`When`) > 1220)
         and hour(`When`) = 14
       group by vLog.Station);
Create or Replace View vSpring As 
(Select vLog.Station
           , Name
           , round(avg(Temperature),1) AvgTemp
           , round(avg(CalcDewPoint),1) AvgDP
        from vLog
           , Xref
       where Xref.Station = vLog.Station
         and (month(`When`) * 100) + day(`When`) between 0321 and 0620
         and hour(`When`) = 14
       group by vLog.Station);
Create or Replace View vSummer As 
(Select vLog.Station
           , Name
           , round(avg(Temperature),1) AvgTemp
           , round(avg(CalcDewPoint),1) AvgDP
        from vLog
           , Xref
       where Xref.Station = vLog.Station
         and (month(`When`) * 100) + day(`When`) between 0621 and 0920
         and hour(`When`) = 14
       group by vLog.Station);
Create or Replace View vAutumn As 
(Select vLog.Station
           , Name
           , round(avg(Temperature),1) AvgTemp
           , round(avg(CalcDewPoint),1) AvgDP
        from vLog
           , Xref
       where Xref.Station = vLog.Station
         and (month(`When`) * 100) + day(`When`) between 0921 and 1220
         and hour(`When`) = 14
       group by vLog.Station);

Create or Replace View AnnualSummary As 
(select vSpring.Station
      , vSpring.Name
      , vWinter.AvgTemp Winter
      , vSpring.AvgTemp Spring
      , vSummer.AvgTemp Summer
      , vAutumn.AvgTemp Autumn
      , Round((vWinter.AvgTemp +
               vSpring.AvgTemp +
               vSummer.AvgTemp +
               vAutumn.AvgTemp) / 4,1) AnnualTemp
      , Round((vWinter.AvgDP +
               vSpring.AvgDP +
               vSummer.AvgDP +
               vAutumn.AvgDP) / 4,1) AnnualDP
   FROM vWinter
      , vSpring
      , vSummer
      , vAutumn
  where vWinter.Station = vSpring.Station
    and vSpring.Station = vSummer.Station
    and vSummer.Station = vAutumn.Station);

Create or Replace View vDailyHighLow As 
(select Station
      , Date(`When`) as `Date`
      , Min(Temperature) as Coldest
      , Max(Temperature) as Warmest
   from vLog
  group by Station
         , Date(`When`));

Create or Replace View vWinterHighLow As 
(select *
   from vDailyHighLow
  where ((month(`Date`) * 100) + day(`Date`) < 0321 or
         (month(`Date`) * 100) + day(`Date`) > 1220));

Create or Replace View vWinterHighLowVsFlem As 
(select a.Station
      , a.`Date`
      , a.Coldest
      , b.Coldest as FlemColdest
      , a.Coldest - b.Coldest as ColdDiff
      , a.Warmest
      , b.Warmest as FlemWarmest
      , a.Warmest - b.Warmest as WarmDiff
   from vDailyHighLow a
      , vDailyHighLow b
  where a.`Date` = b.`Date`
    and b.Station = 'KNJFLEMI11'
    and ((month(a.`Date`) * 100) + day(a.`Date`) < 0321 or
         (month(a.`Date`) * 100) + day(a.`Date`) > 1220));

Create or Replace View vWinterAveragesVsFlem As 
(select a.Station
      , b.`Name`
      , count(*) as Readings
      , avg(Coldest)  as AvgCold
      , avg(Warmest)  as AvgWarm
      , min(Coldest)  as MinCold
      , min(Warmest)  as MinWarm
      , max(Coldest)  as MaxCold
      , max(Warmest)  as MaxWarm
      , avg(ColdDiff) as AvgColdDiff
      , avg(WarmDiff) as AvgWarmDiff
   from vWinterHighLowVsFlem a
      , Xref b
  where b.Station = a.Station
  group by a.Station
  order by 5);

