set pagesize 999
set linesize 132

--
-- script to generate script to add additional redo log groups
-- so that there are a minimum of five groups and each log is 8GB
--
-- works on RAC
--

with mytab as (
  select 
    grp,
    grpoffset,
    thr,
    rank() over (partition by thr order by grp) rnk
  from (
    select 
      rownum grp, 
      tcnt.cnt+rownum grpoffset, 
      1+(trunc((rownum-1)/5)) thr 
    from 
      v$bh,
      ( select count(*) cnt from v$log ) tcnt
    where rownum <= (5*(select max(instance_number) from gv$instance))
  )
)
select 
  'alter database add logfile thread '||xthr||' size 8G blocksize 512;' "--command"
from 
  mytab,
  ( select thread# xthr, count(group#) xgrp from v$log group by thread# ) maxgrp  
where 1=1
and mytab.rnk > maxgrp.xgrp
and mytab.thr = maxgrp.xthr
/
