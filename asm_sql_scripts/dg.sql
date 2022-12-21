col gn              for 99
col diskgroup_name  for a15
col sec_sz          for 99999
col blk_sz          for 99999
col au              for a4
col state           for a10
col type            for a8

col total           for a6
col free            for a6

select 
  vad.group_number "GN",
  vad.name "DISKGROUP_NAME",
  vad.sector_size "SEC_SZ",
  vad.block_size "BLK_SZ",
  decode(floor(vad.allocation_unit_size/1048576),0,
    to_char(vad.allocation_unit_size/1024,'99')||'K',
    to_char(vad.allocation_unit_size/1048576,'99')||'M'
  ) "AU",
  vad.state,
  vad.type "PROT",
  decode(floor(vad.total_mb/1048576),0,
    to_char(vad.total_mb/1024,'9999')||'G',
    to_char(vad.total_mb/1048576,'99.9')||'T'
  ) "TOTAL",
  decode(floor(vad.free_mb/1048576),0,
    to_char(vad.free_mb/1024,'9999')||'G',
    to_char(vad.free_mb/1048576,'99.9')||'T'
  ) "FREE"
from 
  v$asm_diskgroup vad
order by vad.group_number
/
