/* PLSQL function to calculate the delta of IO operations in gv$iostat_file */
/* created by Graham Thornton - gruffdba - Mar 2023 */
/* based on code by Christian Antognini */

drop type iostat_table2;
drop type iostat_record2;


CREATE OR REPLACE TYPE iostat_record2 IS OBJECT (
  date_time    TIMESTAMP,
  SMALL_READS  NUMBER,
  SMALL_WRITES NUMBER,
  LARGE_READS  NUMBER,
  LARGE_WRITES NUMBER,
  SMALL_RMB    NUMBER,
  SMALL_WMB    NUMBER,
  LARGE_RMB    NUMBER,
  LARGE_WMB    NUMBER
);
/

CREATE OR REPLACE TYPE iostat_table2 AS TABLE OF iostat_record2;
/



CREATE OR REPLACE FUNCTION iostat2(p_interval IN NUMBER, p_count IN NUMBER)
   RETURN iostat_table2
   PIPELINED
IS
  l_t1 iostat_record2;
  l_t2 iostat_record2;
  l_out iostat_record2;

BEGIN
  l_t1 := iostat_record2(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  l_t2 := iostat_record2(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

  FOR i IN 1..p_count
  LOOP

    select
      sum(iof.small_read_reqs)       "small_read_reqs",
      sum(iof.small_write_reqs)      "small_write_reqs",
      sum(iof.large_read_reqs)       "large_read_reqs",
      sum(iof.large_write_reqs)      "large_write_reqs",
      sum(iof.small_read_megabytes)  "small_read_megabytes",
      sum(iof.small_write_megabytes) "small_write_megabytes",
      sum(iof.large_read_megabytes)  "large_read_megabytes",
      sum(iof.large_write_megabytes) "large_write_megabytes"
    INTO l_t2.SMALL_READS, l_t2.SMALL_WRITES, l_t2.LARGE_READS, l_t2.LARGE_WRITES, l_t2.SMALL_RMB, l_t2.SMALL_WMB, l_t2.LARGE_RMB, l_t2.LARGE_WMB
    from
      v$database vdb,
      gv$iostat_file iof
    where 1=1
    and vdb.con_id = iof.con_id
    and iof.con_id=0;


    l_out := iostat_record2(systimestamp,
                           (l_t2.SMALL_READS  -l_t1.SMALL_READS  )/p_interval,
                           (l_t2.SMALL_WRITES -l_t1.SMALL_WRITES )/p_interval,
                           (l_t2.LARGE_READS  -l_t1.LARGE_READS  )/p_interval,
                           (l_t2.LARGE_WRITES -l_t1.LARGE_WRITES )/p_interval,
                           (l_t2.SMALL_RMB    -l_t1.SMALL_RMB    )/p_interval,
                           (l_t2.SMALL_WMB    -l_t1.SMALL_WMB    )/p_interval,
                           (l_t2.LARGE_RMB    -l_t1.LARGE_RMB    )/p_interval,
                           (l_t2.LARGE_WMB    -l_t1.LARGE_WMB    )/p_interval
    );


    PIPE ROW(iostat_record2(systimestamp,
                           l_out.SMALL_READS,
                           l_out.SMALL_WRITES,
                           l_out.LARGE_READS,
                           l_out.LARGE_WRITES,
                           l_out.SMALL_RMB,
                           l_out.SMALL_WMB,
                           l_out.LARGE_RMB,
                           l_out.LARGE_WMB));
    l_t1 := l_t2;

    sys.dbms_lock.sleep(p_interval);

  END LOOP;
  RETURN;
END;
/
