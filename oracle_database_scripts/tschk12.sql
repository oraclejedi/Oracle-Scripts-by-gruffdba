col container  for a12
col ts_name    for a20
col bigfile    for a3
col bs         for 999999
col fc         for 999

set pagesize 999
set linesize 132

select
  vc.name "CONTAINER",
  vts.name "TS_NAME",
  vts.bigfile,
  mytsz.bs "BS",
  mytsz.fc "FC",
 -- sum(mytsz.sz),
 -- sum(vfs.file_maxsize),
  --
  substrb(decode(floor(sum(mytsz.sz*mytsz.bs)/1099511627776),0,
    decode(floor(sum(mytsz.sz*mytsz.bs)/1073741824),0,
      decode(floor(sum(mytsz.sz*mytsz.bs)/1048576),0,
        to_char(sum(mytsz.sz*mytsz.bs)/1024,'99999')||'K',
        to_char(sum(mytsz.sz*mytsz.bs)/1048576,'99999')||'M'),
      to_char(sum(mytsz.sz*mytsz.bs)/1073741824,'999.9')||'G'),
    to_char(sum(mytsz.sz*mytsz.bs)/1099511627776,'999.9')||'T'),2,7) "SIZE",
  --
  substrb(decode(floor( ((myfsu.fs-myfsu.al)*mytsz.bs )/1099511627776),0,
    decode(floor( ((myfsu.fs-myfsu.al)*mytsz.bs )/1073741824),0,
      decode(floor( ((myfsu.fs-myfsu.al)*mytsz.bs )/1048576),0,
        to_char( ((myfsu.fs-myfsu.al)*mytsz.bs )/1024,'99999')||'K',
        to_char( ((myfsu.fs-myfsu.al)*mytsz.bs )/1048576,'99999')||'M'),
      to_char( ((myfsu.fs-myfsu.al)*mytsz.bs )/1073741824,'999.9')||'G'),
    to_char( ((myfsu.fs-myfsu.al)*mytsz.bs )/1099511627776,'999.9')||'T'),2,7) "FREE",
   --
   substrb(decode(floor( (myfsu.mx*mytsz.bs)/1099511627776),0,
     decode(floor( (myfsu.mx*mytsz.bs)/1073741824),0,
       decode(floor( (myfsu.mx*mytsz.bs)/1048576),0,
         to_char( (myfsu.mx*mytsz.bs)/1024,'99999')||'K',
         to_char( (myfsu.mx*mytsz.bs)/1048576,'99999')||'M'),
       to_char( (myfsu.mx*mytsz.bs)/1073741824,'999.9')||'G'),
    to_char( (myfsu.mx*mytsz.bs)/1099511627776,'999.9')||'T'),2,7) "MAX"    
from 
  v$containers vc,
  v$tablespace vts,
  (select con_id, ts#, sum(blocks) sz, count(block_size) fc, max(block_size) bs from v$datafile group by con_id, ts#) mytsz,
  ( select 
      con_id,
      tablespace_id,
      sum(file_size) fs,
      sum(file_maxsize) mx,
      sum(allocated_space) al
    from v$filespace_usage
    group by con_id, tablespace_id
  ) myfsu
where 1=1
and vts.con_id = vc.con_id
and vts.con_id = vts.con_id
and vts.con_id = mytsz.con_id
and vts.ts# = mytsz.ts#
--
and vts.con_id = myfsu.con_id (+)
and vts.ts# = myfsu.tablespace_id (+)
--
group by vc.name, vts.name, vts.bigfile, mytsz.bs, mytsz.fc, myfsu.mx, myfsu.fs, myfsu.al
--
order by vc.name, vts.name
/

