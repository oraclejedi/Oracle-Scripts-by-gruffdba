set linesize 132
set pagesize 999

col diskgroup_name for a15

col gn    for 99

col operation   for a20
col state       for a8
col pwr         for 9999
col actual      for 999999
col sofar       for 999999

col est_work    for 999999
col est_min     for 999999
col pct_done    for a8
  
col error_code  for a10

select
  vag.name "DISKGROUP_NAME",
--  vao.group_number "GN",
  vao.operation||':'||vao.pass "OPERATION",
  vao.state,
  vao.power "PWR",
  vao.actual,  
  lpad(to_char(100*(vao.sofar/greatest(1,vao.est_work)),'999.9')||'%',8) "PCT_DONE",
--  vao.sofar,
--  vao.est_work,
  vao.est_minutes "EST_MIN",
  vao.error_code
from
  v$asm_operation vao,
  v$asm_diskgroup vag
where 1=1
and vag.group_number = vao.group_number
/
