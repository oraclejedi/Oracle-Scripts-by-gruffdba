
set pagesize 999
set trimspool on

--
-- generate script to replace all redo logs that do not conform to 8GB size and 512byte blocksize
--

spool logswitch.log

-- switch to 512 and 8G
select 
  'alter database drop logfile group '||group#||';'||chr(10)||chr(13)||
  'alter database add logfile thread '||thread#||' group '||group#||' size 8G blocksize 512;' "--command"
from v$log 
where ( bytes/1048576 != 8192 or blocksize != 512 ) -- expressed in MB
and status != 'CURRENT'
--
union all
--
select 
  'alter system switch logfile;'||chr(10)||chr(13)||
  'alter system archive log current;'||chr(10)||chr(13)||
  'alter system checkpoint;'||chr(10)||chr(13)||
  'alter database drop logfile group '||group#||';'||chr(10)||chr(13)||
  'alter database add logfile thread '||thread#||' group '||group#||' size 8G blocksize 512;' "--command"
from v$log 
where ( bytes/1048576 != 8192 or blocksize != 512 ) -- expressed in MB
and status = 'CURRENT'
/

spool off







