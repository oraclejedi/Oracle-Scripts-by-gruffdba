REM Modified version of database host monitoring code by Graham Thornton - March 2023
REM Original Code by Christian Antognini - May 2009

CREATE OR REPLACE TYPE osstat_record2 IS OBJECT (
  date_time TIMESTAMP,
  idle_time NUMBER,
  user_time NUMBER,
  sys_time NUMBER,
  iowait_time NUMBER,
  nice_time NUMBER,
  busy_time NUMBER
);
/
 
CREATE OR REPLACE TYPE osstat_table2 AS TABLE OF osstat_record2;
/

CREATE OR REPLACE FUNCTION osstat2(p_interval IN NUMBER, p_count IN NUMBER)
   RETURN osstat_table2
   PIPELINED
IS
  l_t1 osstat_record2;
  l_t2 osstat_record2;
  l_out osstat_record2;
  l_total NUMBER;

BEGIN
  l_t1 := osstat_record2(NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  l_t2 := osstat_record2(NULL, NULL, NULL, NULL, NULL, NULL, NULL);
 
  FOR i IN 1..p_count
  LOOP
 
    SELECT sum(decode(stat_name,'IDLE_TIME', value, NULL)) as idle_time,
           sum(decode(stat_name,'USER_TIME', value, NULL)) as user_time,
           sum(decode(stat_name,'SYS_TIME', value, NULL)) as sys_time,
           sum(decode(stat_name,'IOWAIT_TIME', value, NULL)) as iowait_time,
           sum(decode(stat_name,'NICE_TIME', value, NULL)) as nice_time,
           sum(decode(stat_name,'BUSY_TIME', value, NULL)) as busy_time
    INTO l_t2.idle_time, l_t2.user_time, l_t2.sys_time, l_t2.iowait_time, l_t2.nice_time, l_t2.busy_time
    FROM v$osstat
    WHERE stat_name in ('IDLE_TIME','USER_TIME','SYS_TIME','IOWAIT_TIME','NICE_TIME','BUSY_TIME');
    
    l_out := osstat_record2(systimestamp,
                           (l_t2.idle_time-l_t1.idle_time),
                           (l_t2.user_time-l_t1.user_time),
                           (l_t2.sys_time-l_t1.sys_time),
                           (l_t2.iowait_time-l_t1.iowait_time),
                           (l_t2.nice_time-l_t1.nice_time),
                           (l_t2.busy_time-l_t1.busy_time));

    l_total := l_out.idle_time+l_out.busy_time;

    PIPE ROW(osstat_record2(systimestamp,
                           (l_out.idle_time-l_out.iowait_time)/l_total*100,
                           l_out.user_time/l_total*100,
                           l_out.sys_time/l_total*100,
                           l_out.iowait_time/l_total*100,
                           l_out.nice_time/l_total*100,
                           l_out.busy_time/l_total*100));

    l_t1 := l_t2;

    sys.dbms_lock.sleep(p_interval);
    
  END LOOP;
  RETURN;
END;
/
