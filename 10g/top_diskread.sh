#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="disk_usage_${timestamp}.csv"
filename="top_diskread.csv"

sqlplus -s "/ as sysdba" <<EOF > /dev/null

SET TERMOUT OFF
SET ECHO OFF
SET FEEDBACK OFF
SET HEADING ON        
SET UNDERLINE OFF     
SET PAGESIZE 1000     
SET NEWPAGE NONE      
SET LINESIZE 2048      
SET TRIMSPOOL ON      
SET TRIMOUT ON        
SET COLSEP ','        
SET TIMING OFF
SET LONG 200000

COL dskr FORMAT 999999999
COL exec FORMAT 9999999
COL avg_dskr_per_exec FORMAT 999999.9999
COL norm_val FORMAT 999999.99
COL cput_secs FORMAT 999999.9999
COL elap_secs FORMAT 999999.9999
COL sql_id FORMAT a20
COL module_info FORMAT a30
COL sql_text FORMAT a300

SPOOL $filename

SELECT *
  FROM (
    SELECT 
           sqt.dskr,
           sqt.exec,
           DECODE(sqt.exec, 0, NULL, sqt.dskr / sqt.exec) AS avg_dskr_per_exec,
           100 * sqt.dskr / physical_reads.total_reads AS norm_val,
           NVL(sqt.cput / 1000000, NULL) AS cput_secs,
           NVL(sqt.elap / 1000000, NULL) AS elap_secs,
           sqt.sql_id,
           DECODE(sqt.module, NULL, NULL, 'Module: ' || sqt.module) AS module_info,
           '"' || REPLACE(REPLACE(NVL(st.sql_text, '** SQL Text Not Available **'), '"', '""'), CHR(10), ' ') || '"' AS sql_text
      FROM (
        SELECT sql_id,
               MAX(module) AS module,
               SUM(disk_reads_delta) AS dskr,
               SUM(executions_delta) AS exec,
               SUM(cpu_time_delta) AS cput,
               SUM(elapsed_time_delta) AS elap,
               dbid
          FROM dba_hist_sqlstat
         WHERE instance_number = (SELECT instance_number FROM v\$instance)
           AND snap_id > (SELECT MIN(snap_id)
                           FROM dba_hist_snapshot
                          WHERE TRUNC(begin_interval_time) >= TRUNC(SYSDATE - 7)
                            AND instance_number = (SELECT instance_number FROM v\$instance))
           AND snap_id <= (SELECT MAX(snap_id)
                           FROM dba_hist_snapshot
                          WHERE TRUNC(end_interval_time) = TRUNC(SYSDATE)
                            AND instance_number = (SELECT instance_number FROM v\$instance))
         GROUP BY sql_id, dbid
      ) sqt
      LEFT JOIN dba_hist_sqltext st
        ON st.sql_id = sqt.sql_id
       AND st.dbid = sqt.dbid
      CROSS JOIN (
        SELECT SUM(e.value) - SUM(b.value) AS total_reads
          FROM dba_hist_sysstat b, dba_hist_sysstat e
         WHERE b.snap_id = (SELECT MIN(snap_id)
                              FROM dba_hist_snapshot
                             WHERE TRUNC(begin_interval_time) >= TRUNC(SYSDATE - 7)
                               AND instance_number = (SELECT instance_number FROM v\$instance))
           AND e.snap_id = (SELECT MAX(snap_id)
                              FROM dba_hist_snapshot
                             WHERE TRUNC(end_interval_time) = TRUNC(SYSDATE)
                               AND instance_number = (SELECT instance_number FROM v\$instance))
           AND b.dbid = e.dbid
           AND b.instance_number = e.instance_number
           AND e.stat_name = 'physical reads'
           AND b.stat_name = 'physical reads'
      ) physical_reads
     WHERE physical_reads.total_reads > 0
     ORDER BY NVL(sqt.dskr, -1) DESC, sqt.sql_id
  )
 WHERE ROWNUM < 21
   AND (ROWNUM <= 10 OR norm_val > 1);

SPOOL OFF
EOF

