set linesize 132
set pagesize 999

col db_name   for a7
col instance  for a8
col disk_name for a15

col reads     for 99999999
col writes    for 99999999

col rd_tm     for 9999.9
col wr_tm     for 9999.9

col rd_sz  for a6
col wr_sz  for a6 

col rd_err for 999999
col wr_err for 999999

col diskgroup_name  for a15

select 
  vadi.dbname "DB_NAME",
  vadi.instname "INSTANCE",
  vd.name "DISK_NAME",
  vad.name "DISKGROUP_NAME",
--  vadi.reads,
--  vadi.writes,
  vadi.read_time "RD_TM",
  vadi.write_time "WR_TM",
  decode(floor(vadi.bytes_read/1073741824),0,
    decode(floor(vadi.bytes_read/1048576),0,
        to_char(vadi.bytes_read/1024,'9999')||'K',
      to_char(vadi.bytes_read/1048576,'9999')||'M'
    ), to_char(vadi.bytes_read/1073741824,'9999')||'G'
  ) "RD_SZ",
  decode(floor(vadi.bytes_written/1073741824),0,
    decode(floor(vadi.bytes_written/1048576),0,
        to_char(vadi.bytes_written/1024,'9999')||'K',
      to_char(vadi.bytes_written/1048576,'9999')||'M'
    ), to_char(vadi.bytes_written/1073741824,'9999')||'G'
  ) "WR_SZ",
  vadi.read_errs "RD_ERR",
  vadi.write_errs "WR_ERR"
from 
  v$asm_disk_iostat vadi,
  v$asm_disk vd,
  v$asm_diskgroup vad
where 1=1
and vadi.group_number = vd.group_number
and vadi.group_number = vad.group_number
and vadi.disk_number = vd.disk_number
order by 
  vadi.dbname, vadi.instname, vad.name, vd.name
/

