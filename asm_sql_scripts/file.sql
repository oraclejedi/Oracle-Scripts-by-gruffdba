set linesize 132
set pagesize 999

col gn             for 99
col fn             for 99999
col blk_sz         for 99999
col str_sz         for a6
col file_type      for a16

col size           for a8
col tot            for a6
col free           for a6

col file_name      for a60
col diskgroup_name for a15

select 
  vaf.file_number "FN",
  vad.name "DISKGROUP_NAME",
--  vaf.group_number "GN",
  vaf.block_size "BLK_SZ",
  decode(vaf.striped,'COARSE',stripe_size.extent,stripe_size.stripsz) "STR_SZ",
  decode(floor(vaf.bytes/1099511627776),0,
    decode(floor(vaf.bytes/1073741824),0,
      decode(floor(vaf.bytes/1048576),0,
        to_char(vaf.bytes/1024,'9999')||'K',
        to_char(vaf.bytes/1048576,'9999')||'M'
      ),
      to_char(vaf.bytes/1073741824,'9999')||'G'
    ),
    to_char(vaf.bytes/1099511627776,'99.9')||'T'
  ) "SIZE",
  vaf.type "FILE_TYPE",
  vaa3.name||'/'||vaa2.name||'/'||vaa1.name "FILE_NAME"
from
  v$asm_diskgroup vad,
  v$asm_file vaf,
  v$asm_alias vaa1,
  v$asm_alias vaa2,
  v$asm_alias vaa3,
  (
  select 
    decode(floor(y1.ksppstvl/1048576),0,
      to_char(y1.ksppstvl/1024,'9999')||'K',
      to_char(y1.ksppstvl/1048576,'9999')||'M'
    ) "STRIPSZ",
    decode(floor(y2.ksppstvl/1048576),0,
        to_char(y2.ksppstvl/1024,'9999')||'K',
        to_char(y2.ksppstvl/1048576,'9999')||'M'
    ) "EXTENT",
    y1.ksppstvl,
    y2.ksppstvl
  from 
    x$ksppcv y1,
    x$ksppi x1,
    x$ksppcv y2,
    x$ksppi x2
  where 1=1
  and x1.indx = y1.indx
  and x1.ksppinm ='_asm_stripesize'
  and x2.indx = y2.indx
  and x2.ksppinm ='_asm_ausize'  
  ) stripe_size
where 1=1
and vaf.group_number = vad.group_number
and vaf.group_number = vaa1.group_number
and vaf.file_number = vaa1.file_number
and vaf.incarnation = vaa1.file_incarnation
and vaa1.parent_index = vaa2.reference_index
and vaa2.parent_index = vaa3.reference_index
order by
  vaf.file_number,
  vaf.group_number
/
