col gn              for 99
col diskgroup_name  for a15
col sec_sz          for 99999
col blk_sz          for 99999
col au              for a4
col state           for a10
col type            for a8

col total           for a6
col free            for a6

col disks           for 99999

select
  vad.group_number "GN",
  max(vad.name) "DISKGROUP_NAME",
  max(vad.sector_size) "SEC_SZ",
  max(vad.block_size) "BLK_SZ",
  max(decode(floor(vad.allocation_unit_size/1048576),0,
    to_char(vad.allocation_unit_size/1024,'99')||'K',
    to_char(vad.allocation_unit_size/1048576,'99')||'M'
  )) "AU",
  max(vad.state) "STATE",
  max(vad.type) "PROT",
  max(decode(floor(vad.total_mb/1048576),0,
    to_char(vad.total_mb/1024,'9999')||'G',
    to_char(vad.total_mb/1048576,'99.9')||'T'
  )) "TOTAL",
  max(decode(floor(vad.free_mb/1048576),0,
    to_char(vad.free_mb/1024,'9999')||'G',
    to_char(vad.free_mb/1048576,'99.9')||'T'
  )) "FREE",
  count( dsk.disk_number ) DISKS
from
  v$asm_diskgroup vad,
  v$asm_disk dsk
where 1=1
and vad.group_number=dsk.group_number
group by vad.group_number
order by vad.group_number
/
