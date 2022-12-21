-- 
--
-- script to generate ASM collections

--
-- connect as a SYSASM privileged account 
--
set echo off
set heading off
set feedback off
set pagesize 50000
set linesize 999
set trimspool on

whenever sqlerror continue

prompt
prompt
prompt
prompt EMC ASM Oracle Collection Tool
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt 


--
-- create a spool file
--
spool asm_collect.log


@@diskgroup.sql
@@disk11.sql
@@file.sql
@@attributes.sql


spool off

prompt
prompt
--
--

