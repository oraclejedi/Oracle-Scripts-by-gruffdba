col device for a12
col size   for a7

select /*+ rule */
  substrb(vd.name,1,12) DEVICE,
  substrb(
  decode(floor(sum(vd.bytes)/1099511627776),0,
    decode(floor(sum(vd.bytes)/1073741824),0,
      decode(floor(sum(vd.bytes)/1048576),0,
        to_char(sum(vd.bytes)/1024,'999999')||'K',
        to_char(sum(vd.bytes)/1048576,'999999')||'M'),
      to_char(sum(vd.bytes)/1073741824,'9999.9')||'G'),
    to_char(sum(vd.bytes)/1099511627776,'9999.9')||'T')
  ,2,8) "SIZE",
  to_char(count(unique(vd.file#)),'9999') FC,
  to_char((sum(vfs.phyrds)/max(my_filestat.sum_phyrds))*100,'999.9')||'%' "PC_RD",
  to_char((sum(vfs.phywrts)/max(my_filestat.sum_phywrts))*100,'999.9')||'%' "PC_WR",
  to_char(avg(vfs.readtim/greatest(vfs.phyrds,1)),'999.99') RDTM_MS,
  to_char(avg(vfs.writetim/greatest(vfs.phywrts,1)),'999.99') WRTM_MS,
  to_char(avg(vfs.maxiortm),'9,999.99') MXRD_MS,
  to_char(avg(vfs.maxiowtm),'9,999.99') MXWR_MS
from v$datafile vd, v$filestat vfs, (
  select /*+ rule */
    sum(phywrts) "SUM_PHYWRTS",
    sum(phyrds) "SUM_PHYRDS"
  from v$filestat ) my_filestat
where 1=1
and vd.file# = vfs.file#
group by substrb(vd.name,1,12)
--
--
union all
--
--
select /*+ rule */
   '{all}',
   substrb(
   decode(floor(sum(vd.bytes)/1099511627776),0,
     decode(floor(sum(vd.bytes)/1073741824),0,
       decode(floor(sum(vd.bytes)/1048576),0,
         to_char(sum(vd.bytes)/1024,'999999')||'K',
         to_char(sum(vd.bytes)/1048576,'999999')||'M'),
       to_char(sum(vd.bytes)/1073741824,'9999.9')||'G'),
     to_char(sum(vd.bytes)/1099511627776,'9999.9')||'T')
   ,2,8) "SIZE",
   to_char(count(unique(vd.file#)),'9999') FC,
   null,null,
   to_char(avg(vf.readtim/greatest(vf.phyrds,1)),'999.99') RDTM_MS,
   to_char(avg(vf.writetim/greatest(vf.phywrts,1)),'999.99') WRTM_MS,
   to_char(avg(vf.maxiortm),'9,999.99') MXRD_MS,
   to_char(avg(vf.maxiowtm),'99999.99') MXWR_MS
from v$datafile vd, v$filestat vf
where vd.file# = vf.file#
/