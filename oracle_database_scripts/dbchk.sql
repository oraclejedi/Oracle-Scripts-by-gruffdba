--
-- show a quick overview of the instance
--

set linesize 132

select /*+ RULE CURSOR_SHARING_EXACT */
  substrb(max(name),1,6) NAME,
  substrb(max(version),1,9) VERSION,
  substrb(to_char(max(startup_time),'DD-MON-YY'),1,9) STARTED,
  substrb(decode(max(log_mode),'NOARCHIVELOG','NOARCH','ARCH'),1,5) LOGMD,
  decode(max(archiver),'STOPPED','NO','YES') ARC,
  decode(max(logins),'ALLOWED','NO','YES') RM,
  substrb(max(parallel),1,3) OPS,
  to_char(max(E4031),'9999') "4031",
  --
  substrb(decode(floor(max(pool_mb)/1073741824),0,
    decode(floor(max(pool_mb)/1048576),0,
      to_char(max(pool_mb)/1024,'9999')||'K',
      to_char(max(pool_mb)/1048576,'9999')||'M'),
    to_char(max(pool_mb)/1073741824,'99.9')||'G'),2,6) POOL,
  --
  substrb(decode(floor(max(large)/1073741824),0,
    decode(floor(max(large)/1048576),0,
      to_char(max(large)/1024,'9999')||'K',
      to_char(max(large)/1048576,'9999')||'M'),
    to_char(max(large)/1073741824,'99.9')||'G'),2,6) LARGE,
  --
  substrb(decode(floor(max(dbf_mb)/1073741824),0,
    decode(floor(max(dbf_mb)/1048576),0,
      to_char(max(dbf_mb)/1024,'9999')||'K',
      to_char(max(dbf_mb)/1048576,'9999')||'M'),
    to_char(max(dbf_mb)/1073741824,'99.9')||'G'),2,6) CACH,
  --
  substrb(decode(floor(max(log_kb)/1073741824),0,
    decode(floor(max(log_kb)/1048576),0,
      to_char(max(log_kb)/1024,'9999')||'K',
      to_char(max(log_kb)/1048576,'9999')||'M'),
    to_char(max(log_kb)/1073741824,'99.9')||'G'),2,6) LOG,
  --
  substrb(decode(floor(max(pga_sz)/1073741824),0,
    decode(floor(max(pga_sz)/1048576),0,
      to_char(max(pga_sz)/1024,'9999')||'K',
      to_char(max(pga_sz)/1048576,'9999')||'M'),
    to_char(max(pga_sz)/1073741824,'99.9')||'G'),2,6) PGA,
  --
  substrb(decode(floor(max(jav_sz)/1073741824),0,
    decode(floor(max(jav_sz)/1048576),0,
      to_char(max(jav_sz)/1024,'9999')||'K',
      to_char(max(jav_sz)/1048576,'9999')||'M'),
    to_char(max(jav_sz)/1073741824,'99.9')||'G'),2,6) JAVA 
from 
(
  select
    vd.name name, 
    vi.version version,
    vi.startup_time startup_time,
    vd.log_mode log_mode,
    vi.archiver archiver,
    vi.logins logins,
    vi.parallel parallel,
    xk.kghlunfu e4031,
    vp1.value POOL_MB,
    to_number(vp2.value*vp3.value) DBF_MB,
    vp4.value LOG_KB,
    vp5.value PGA_SZ,
    '0' JAV_SZ,
    vp6.value LARGE
  from 
    v$database vd, 
    v$instance vi, 
    sys.x$kghlu xk, 
    v$parameter vp1, 
    v$parameter vp2, 
    v$parameter vp3, 
    v$parameter vp4, 
    v$parameter vp5,
    v$parameter vp6
  where 1=1
  and vp1.name = 'shared_pool_size'
  and vp2.name = 'db_block_buffers'
  and vp2.value != '0'
  and vp3.name = 'db_block_size'
  and vp4.name = 'log_buffer'
  and vp5.name = 'sort_area_size'
  and vp6.name = 'large_pool_size'
  --
  union all
  --
  select
    vd.name,
    vi.version,
    vi.startup_time,
    vd.log_mode,
    vi.archiver archiver,
    vi.logins logins,
    vi.parallel parallel,
    xk.kghlunfu e4031,
    vp1.value POOL_MB,
    to_number(vp2.value) DBF_MB,
    vp4.value LOG_KB,
    vp5.value PGA_SZ,
    vp6.value JAV_SZ,
    vp7.value LARGE
  from 
    v$database vd, 
    v$instance vi, 
    sys.x$kghlu xk, 
    v$parameter vp1, 
    v$parameter vp2, 
    v$parameter vp4, 
    v$parameter vp5, 
    v$parameter vp6,
    v$parameter vp7
  where 1=1
  and vp1.name = 'shared_pool_size'
  and vp2.name = 'db_cache_size'
  and vp4.name = 'log_buffer'
  and vp5.name = 'pga_aggregate_target' 
  and vp6.name = 'java_pool_size'
  and vp7.name = 'large_pool_size'
)
/

