--
-- show status of all online redo logs
--

select /*+ RULE CURSOR_SHARING_EXACT */
  substrb(le.lethr,1,3) THR,
  substrb(le.indx+1,1,3) GRP,
  substrb(le.leseq,1,6) SEQ,
  substrb(decode(floor((le.lesiz*le.lebsz)/1073741824),0,
    decode(floor((le.lesiz*le.lebsz)/1048576),0,
      to_char((le.lesiz*le.lebsz)/1024,'9999')||'K',
      to_char((le.lesiz*le.lebsz)/1048576,'9999')||'M'),
    to_char((le.lesiz*le.lebsz)/1073741824,'99.9')||'G'),2,6) "SIZE",
  decode(bitand(le.leflg,1),0,'NO','YES') ARC,
  decode(bitand(le.leflg,24),8,'CUR',16,'CLR',24,'CLC',
  decode(sign(leseq),0,'UNU',decode(sign((to_number(rt.rtckp_scn)-
    to_number(le.lenxs))* bitand(rt.rtsta,2)),-1,'ACT','INA'))) STA,
  substrb(lpad(substrb(decode(trunc(sysdate-to_date(le.lelot,'MM/DD/RR HH24:MI:SS')),0,
    to_char(to_date(trunc(86399*mod(sysdate-to_date(le.lelot,
    'MM/DD/RR HH24:MI:SS'),1)),'SSSSS'),'HH24:MI:SS'),
    trunc(sysdate-to_date(le.lelot,'MM/DD/RR HH24:MI:SS'))),1,8),8),1,8) "AG-D/HMS",
  decode(cp.cpodr_bno,null,'   n/a',to_char(100*cp.cpodr_bno/le.lesiz,'99.9')||'%') PC_USD,
  substrb(decode(ascii(substrb(fn.fnnam,35,1)),NULL,fn.fnnam,
    substrb(fn.fnnam,1,6)||'..'||
    substrb(fn.fnnam,greatest(length(fn.fnnam)-26,0),27)),1,35) DB_LOGFILE
from sys.x$kccle le, sys.x$kccfn fn, sys.x$kccrt rt, sys.x$version xv
, sys.x$kcccp cp
where le.ledup!=0
and le.leseq=cp.cpodr_seq(+)
and le.lethr=rt.rtnum 
and le.inst_id = rt.inst_id
and le.indx+1=fn.fnfno
and fn.fnnam is not null
and xv.banner like 'Oracle%'
and fntyp=(decode(substrb(xv.banner,7,1),'7',2,3))
order by 1,2,8
/
