/* PLSQL function to calculate the delta of IO operations in gv$filestat */
/* created by Graham Thornton - gruffdba - Mar 2023 */
/* based on code by Christian Antognini */


drop type iostat_table;
drop type iostat_record;


CREATE OR REPLACE TYPE iostat_record IS OBJECT (
  date_time TIMESTAMP,
  PHYRDS    NUMBER,
  PHYWRTS   NUMBER,
  PHYBLKRD  NUMBER,
  READBYTES NUMBER,
  AVG_MS    NUMBER,
  AVGIOTIM  NUMBER
);
/

CREATE OR REPLACE TYPE iostat_table AS TABLE OF iostat_record;
/

CREATE OR REPLACE FUNCTION iostat(p_interval IN NUMBER, p_count IN NUMBER)
   RETURN iostat_table
   PIPELINED
IS
  l_t1 iostat_record;
  l_t2 iostat_record;
  l_out iostat_record;

BEGIN
  l_t1 := iostat_record(NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  l_t2 := iostat_record(NULL, NULL, NULL, NULL, NULL, NULL, NULL);

  FOR i IN 1..p_count
  LOOP

    select
      sum(vfs.PHYRDS) as "PHYRDS",
      sum(vfs.PHYWRTS) as "PHYWRTS",
      sum(vfs.PHYBLKRD) as "PHYBLKRD",
      (sum(vfs.PHYBLKRD*vbs.block_size)) as "READBYTES",
      avg(vfs.SINGLEBLKRDTIM/vfs.SINGLEBLKRDS) as "AVG_MS",
      avg(vfs.AVGIOTIM) as AVGIOTIM
    INTO l_t2.PHYRDS, l_t2.PHYWRTS, l_t2.PHYBLKRD, l_t2.READBYTES, l_t2.AVG_MS, l_t2.AVGIOTIM
    from
      gv$filestat vfs,
      v$datafile vbs,
      v$database vdb
    where 1=1
    and vdb.con_id = vfs.con_id
    and vdb.con_id = vbs.con_id
    and vfs.file# = vbs.file#;

    l_out := iostat_record(systimestamp,
                           (l_t2.PHYRDS    -l_t1.PHYRDS   )/p_interval,
                           (l_t2.PHYWRTS   -l_t1.PHYWRTS  )/p_interval,
                           (l_t2.PHYBLKRD  -l_t1.PHYBLKRD )/p_interval,
                           (l_t2.READBYTES -l_t1.READBYTES )/p_interval,
                           (l_t2.AVG_MS),
                           (l_t2.AVGIOTIM)
    );


    PIPE ROW(iostat_record(systimestamp,
                           l_out.PHYRDS,
                           l_out.PHYWRTS,
                           l_out.PHYBLKRD,
                           l_out.READBYTES,
                           l_out.AVG_MS,
                           l_out.AVGIOTIM));
    l_t1 := l_t2;

    sys.dbms_lock.sleep(p_interval);

  END LOOP;
  RETURN;
END;
/

