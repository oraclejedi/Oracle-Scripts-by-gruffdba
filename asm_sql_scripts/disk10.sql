set linesize 132
set pagesize 999

col diskgroup_name for a15

col dsk   for 999
col gn    for 99
col hdr_sta for a11
col mnt_sta for a7

col free  for a6
col os_sz for a6
col total for a6

col path  for a30
col raid  for a8
col state for a10

col disk_name for a12

select
  vad.name "DISK_NAME",
  vag.name "DISKGROUP_NAME",
--  vad.group_number "GN",
--  vad.voting_file
  vad.disk_number "DSK",
  vad.mount_status "MNT_STA",
  vad.header_status "HDR_STA",
  vad.state,
--  vad.redundancy "RAID",
--  decode(floor(vad.os_mb/1048576),0,
--    to_char(vad.os_mb/1024,'9999')||'G',
--    to_char(vad.os_mb/1048576,'9999')||'T'
--  ) "OS_SZ",
  decode(floor(vad.total_mb/1048576),0,
    to_char(vad.total_mb/1024,'9999')||'G',
    to_char(vad.total_mb/1048576,'9999')||'T'
  ) "TOTAL",
  decode(floor(vad.free_mb/1048576),0,
    to_char(vad.free_mb/1024,'9999')||'G',
    to_char(vad.free_mb/1048576,'9999')||'T'
  ) "FREE",
  vad.path
from
  v$asm_disk vad,
  v$asm_diskgroup vag
where 1=1
and vad.group_number = vag.group_number(+)
order by vag.name, vad.name
/
