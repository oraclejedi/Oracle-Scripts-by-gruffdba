
-- drop the second member of every redo log group
-- works on RAC
-- uncomment CON_ID for pluggablle databases

-- to prevent mirrored redo, explicitly set the db_create_online_log_dest_1
-- alter system set db_create_online_log_dest_1='+DATA';

-- alter system archive log current;

set linesize 200
set pagesize 999

select unique
  'alter database drop logfile member '||chr(39)||gvl.member||chr(39)||';' "-- command"
from 
  gv$logfile gvl,
  gv$log gl
where 1=1
--and gvl.con_id = gl.con_id
and gvl.group# = gl.group#
and gl.members > 1
and gl.status != 'CURRENT'
and gvl.member not in ( select min(gvl2.member) from gv$logfile gvl2 group by gvl2.group# )
union all
select 'alter system archive log current;' from dual
union all
select unique
  'alter database drop logfile member '||chr(39)||gvl.member||chr(39)||';' "-- command"
from 
  gv$logfile gvl,
  gv$log gl
where 1=1
--and gvl.con_id = gl.con_id
and gvl.group# = gl.group#
and gl.members > 1
and gl.status = 'CURRENT'
and gvl.member not in ( select min(gvl2.member) from gv$logfile gvl2 group by gvl2.group# )
/

