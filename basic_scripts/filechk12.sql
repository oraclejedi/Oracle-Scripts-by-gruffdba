
set linesize 132
set pagesize 999

col db_file   for a57
col ts_name   for a12
col container for a12
col size      for a6

select /*+ RULE CURSOR_SHARING_EXACT */
  substrb(decode(ascii(substrb(vd.name,57,1)),NULL,vd.name,
    substrb(vd.name,1,12)||'..'|| -- first 14 chars
    substrb(vd.name,greatest(length(vd.name)-(57-14-1),0),(57-14))),1,57) DB_FILE,
  vs.name TS_NAME,
--  vd.con_id,
  vc.name CONTAINER,
  substrb(decode(floor(vd.bytes/1099511627776),0,    
    decode(floor(vd.bytes/1073741824),0,
      decode(floor(vd.bytes/1048576),0,
        to_char(vd.bytes/1024,'99999')||'K',
        to_char(vd.bytes/1048576,'99999')||'M'),
      to_char(vd.bytes/1073741824,'999.9')||'G'),
    to_char(vd.bytes/1099511627776,'999.9')||'T'),2,7) "SIZE",
  substrb(decode(nvl(vb.status,'X'),'ACTIVE','BAK',vd.status),1,3) STA,
  substrb(to_char((vfs.phyrds/greatest(myfst1.sum_phyrds,1))*100,'99.9')||'%',2,5) PC_RD,
  substrb(to_char((vfs.phywrts/greatest(myfst1.sum_phywrts,1))*100,'99.9')||'%',2,5) PC_WR,
  substrb(to_char((vfs.phyrds+vfs.phywrts)/greatest(vfs.phyblkrd+vfs.phyblkwrt,1),'9.9'),2,4) EFF
from v$containers vc, v$datafile vd, v$tablespace vs, v$backup vb, v$filestat vfs, (
  select 
    sum(phyrds) sum_phyrds,
    sum(phywrts) sum_phywrts
  from v$filestat ) myfst1
where 1=1
and vc.con_id = vd.con_id
and vd.file# = vfs.file#
and vd.ts# = vs.ts#
and vd.con_id = vs.con_id
and vd.file# = vb.file#(+)
--
--
union all
--
--
select
  substrb(decode(ascii(substrb(vt.name,57,1)),NULL,vt.name,
    substrb(vt.name,1,12)||'..'|| -- first 14
    substrb(vt.name,greatest(length(vt.name)-(57-14-1),0),(57-14))),1,57) DB_FILE,
  max(vs.name),
--  vt.con_id,
  vc.name,
  substrb(decode(floor(vt.bytes/1099511627776),0,    
    decode(floor(vt.bytes/1073741824),0,
      decode(floor(vt.bytes/1048576),0,
        to_char(vt.bytes/1024,'99999')||'K',
        to_char(vt.bytes/1048576,'99999')||'M'),
      to_char(vt.bytes/1073741824,'999.9')||'G'),
    to_char(vt.bytes/1099511627776,'999.9')||'T'),2,7) "SIZE",    
  'TMP' STA,
  null,null,null
from v$containers vc, v$tempfile vt, v$tablespace vs
where 1=1
and vc.con_id = vt.con_id
and vt.ts# = vs.ts#
and vt.con_id = vs.con_id 
group by vt.name, vc.name, vt.bytes
--
--
order by 3,2,1
/