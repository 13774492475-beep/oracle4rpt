#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="cpu_usage_${timestamp}.csv"
filename="top_cpueps.csv"

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

COL cput_secs FORMAT 999999.9999
COL elap_secs FORMAT 999999.9999
COL exec FORMAT 99999
COL avg_cput_secs FORMAT 999999.9999
COL norm_val FORMAT 999999.99
COL sql_id FORMAT a20
COL module_info FORMAT a30
COL sql_text FORMAT a300

SPOOL $filename

SELECT *
  FROM (
    SELECT NVL(sqt.cput / 1000000, TO_NUMBER(NULL)) AS cput_secs,
           NVL(sqt.elap / 1000000, TO_NUMBER(NULL)) AS elap_secs,
           sqt.exec,
           DECODE(sqt.exec, 0, TO_NUMBER(NULL), sqt.cput / sqt.exec / 1000000) AS avg_cput_secs,
           100 * (sqt.elap / db_time.dbtime) AS norm_val,
           sqt.sql_id,
           DECODE(sqt.module, NULL, NULL, 'Module: ' || sqt.module) AS module_info,
           '"' || REPLACE(REPLACE(NVL(st.sql_text, '** SQL Text Not Available **'), '"', '""'), CHR(10), ' ') || '"' AS sql_text
      FROM (
        SELECT sql_id,
               MAX(module) AS module,
               SUM(cpu_time_delta) AS cput,
               SUM(elapsed_time_delta) AS elap,
               SUM(executions_delta) AS exec,
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
         GROUP BY sql_id, dbid) sqt
      LEFT JOIN dba_hist_sqltext st
        ON st.sql_id = sqt.sql_id
       AND st.dbid = sqt.dbid
      CROSS JOIN (
        SELECT SUM(e.value) - SUM(b.value) AS dbtime
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
           AND e.stat_name = 'DB time'
           AND b.stat_name = 'DB time'
      ) db_time
     ORDER BY NVL(sqt.cput, -1) DESC, sqt.sql_id
  )
 WHERE ROWNUM < 21
   AND (ROWNUM <= 10 OR norm_val > 1);

SPOOL OFF
EOF

