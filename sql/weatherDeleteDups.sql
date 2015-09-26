delete from Log where id in (select id from (select a.Station, a.`When`, max(id) as id from Log a join (select Station, `When`, count(*) from Log group by Station, `When` having count(*) > 1) b on b.Station = a.Station and b.`When` = a.`When` group by Station, `When`) x);

