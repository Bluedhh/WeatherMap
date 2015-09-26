use weather;
select NF.Station
     , NF.Name
     , NF.Winter
     , NF.Spring
     , NF.Summer
     , NF.Autumn
     , NF.AnnualTemp
     , NF.AnnualDP
     , NF.Winter - F.Winter WinterVsFlem
     , NF.Spring - F.Spring SpringVsFlem
     , NF.Summer - F.Summer SummerVsFlem
     , NF.Autumn - F.Autumn AutumnVsFlem
     , NF.AnnualTemp - F.AnnualTemp AnnualVsFlem
     , NF.AnnualDP - F.AnnualDP DPVsFlem
  from AnnualSummary F
     , AnnualSummary NF
 where F.Station = 'KNJFLEMI11'
--   and NF.Station <> 'KNJFLEMI11'
   and NF.AnnualDP - F.AnnualDP <= 50
 order by NF.AnnualTemp;

