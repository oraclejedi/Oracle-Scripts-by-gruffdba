-- script to io balance across devices

clear columns

select /*+ rule */
  substrb(vd.file_name,1,6) DEVICE,
  substrb(
    decode(floor(sum(vd.bytes)/1099511627776),0,
      decode(floor(sum(vd.bytes)/1073741824),0,
        decode(floor(sum(vd.bytes)/1048576),0,
          to_char(sum(vd.bytes)/1024,'999999')||'K',
          to_char(sum(vd.bytes)/1048576,'999999')||'M'),
        to_char(sum(vd.bytes)/1073741824,'9999.9')||'G'),
      to_char(sum(vd.bytes)/1099511627776,'9999.9')||'T')
  ,2,8) "SIZE",
  to_char(count(unique(vd.file_id)),'9999') FC,
  to_char((sum(vf.phyrds)/max(my_filestat.sum_phyrds))*100,'999.9')||'%' "PC_RD",
  to_char((sum(vf.phywrts)/max(my_filestat.sum_phywrts))*100,'999.9')||'%' "PC_WR",
  to_char(avg(vf.readtim/greatest(vf.phyrds,1)),'999.99') RDTM_MS,
  to_char(avg(vf.writetim/greatest(vf.phywrts,1)),'999.99') WRTM_MS,
  to_char(avg(vf.maxiortm),'9,999.99') MXRD_MS,
  to_char(avg(vf.maxiowtm),'9,999.99') MXWR_MS
from dba_data_files vd, v$filestat vf, (
  select /*+ rule */
    sum(phywrts) "SUM_PHYWRTS", 
    sum(phyrds) "SUM_PHYRDS" 
  from v$filestat ) my_filestat 
where vd.file_id = vf.file#
group by substrb(vd.file_name,1,6)
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
  to_char(count(unique(vd.file_id)),'9999') FC,
  null,null,
  to_char(avg(vf.readtim/greatest(vf.phyrds,1)),'999.99') RDTM_MS,
  to_char(avg(vf.writetim/greatest(vf.phywrts,1)),'999.99') WRTM_MS,
  to_char(avg(vf.maxiortm),'9,999.99') MXRD_MS,
  to_char(avg(vf.maxiowtm),'9,999.99') MXWR_MS
from dba_data_files vd, v$filestat vf
where vd.file_id = vf.file#
--
--
order by 5 desc
/



