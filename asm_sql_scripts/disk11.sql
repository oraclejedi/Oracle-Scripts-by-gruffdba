set linesize 132
set pagesize 999

col disk_name      for a25
col diskgroup_name for a20

col dsk            for 999
col gn             for 99
col hdr_sta        for a11
col mnt_sta        for a7

col free           for a6
col os_sz          for a6
col total          for a6

col path           for a50
col raid           for a8
col state          for a10

col rdtm           for 999.999
col wrtm           for 999.999

select
  vad.name "DISK_NAME",
  vag.name "DISKGROUP_NAME",
--  vad.group_number "GN",
--  vad.voting_file,
  vad.read_time/greatest(1,vad.reads) "RDTM",
  vad.write_time/greatest(1,vad.writes) "WRTM",
  vad.disk_number "DSK",
  vad.mount_status "MNT_STA",
  vad.header_status "HDR_STA",
  vad.state,
--  vad.redundancy "RAID",
--  decode(floor(vad.os_mb/1048576),0,
--    to_char(vad.os_mb/1024,'9999')||'G',
--    to_char(vad.os_mb/1048576,'99.9')||'T'
--  ) "OS_SZ",
  decode(floor(vad.total_mb/1048576),0,
    to_char(vad.total_mb/1024,'9999')||'G',
    to_char(vad.total_mb/1048576,'99.9')||'T'
  ) "TOTAL",
--  decode(floor(vad.free_mb/1048576),0,
--    to_char(vad.free_mb/1024,'9999')||'G',
--    to_char(vad.free_mb/1048576,'99.9')||'T'
--  ) "FREE",
  vad.path
from
  v$asm_disk vad,
  v$asm_diskgroup vag
where 1=1
and vad.group_number = vag.group_number(+)
order by vag.name, vad.name
/




