-- verify redo logs

set linesize 132

col group# for 9999
col thread# for 9999
col member for a60
col bs for 999

select 
  vl.group#, 
  vl.thread#, 
  vl.bytes/1048576 "SIZE_MB",
  vl.blocksize "BS", 
  vl.members,
  vf.type,
  vf.member 
from 
  v$log vl,
  v$logfile vf
where 1=1
and vl.group# = vf.group#
order by
  vl.thread#,
  vl.group#
/




