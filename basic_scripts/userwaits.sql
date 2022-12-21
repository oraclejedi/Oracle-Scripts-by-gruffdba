--
-- show what each session is doing right now
--

set linesize 132
set pagesize 999

select /*+ RULE CURSOR_SHARING_EXACT */
  substrb(vs.username,1,10) db_user,
--  substrb(vs.osuser,1,10) os_user,
  substrb(vs.machine,1,10) machine,
  substrb(vs.server,1,1)||substrb(to_char(vs.sid),1,4) "I-SID",
  substrb(to_char(vs.serial#),1,4) srl,
  substrb(vp.spid,1,8) spid,
  vs.sql_address sql_addr,
  substrb(vw.event,1,27) event, 
  substrb(vw.p1text||':'||vw.p1,1,15) msg1,
  substrb(vw.p2text||decode(vw.p2text,null,null,':'||vw.p2),1,15) msg2,
--  substrb(vw.p3text||decode(vw.p3text,null,null,':'||vw.p3),1,15) msg3,
  substrb(lpad(
    decode(
      trunc(vw.seconds_in_wait/86399),0,null,
      to_char(trunc(vw.seconds_in_wait/86399))||':')||
    to_char(to_date(mod(vw.seconds_in_wait,86399),'SSSSS'),'HH24:MI:SS'),11),1,11) "TM-DHMS"
from v$session vs, v$process vp, v$session_wait vw
where ( vw.event not like '%SQL%' or vs.status = 'ACTIVE' )
and vw.sid = vs.sid
and vs.paddr = vp.addr(+)
order by vw.sid, 6
/
