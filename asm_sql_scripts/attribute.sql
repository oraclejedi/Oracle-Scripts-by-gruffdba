
set linesize 132
set pagesize 999

col diskgroup_name a15

col name  for a45
col value for a10
col atidx for 99999
col atinc for 99999
col gn    for 99
col ronly for a5
col sys   for a4

select
  vad.name "DISKGROUP_NAME",
  vaa.name,
  vaa.value,
--  vaa.group_number "GN",
--  vaa.attribute_index "ATIDX",
--  vaa.attribute_incarnation "ATINC",  
  vaa.read_only "RONLY",
  vaa.system_created "SYS"
from 
  v$asm_attribute vaa,
  v$asm_diskgroup vad
where 1=1
and vaa.group_number = vad.group_number
order by vaa.name
/




