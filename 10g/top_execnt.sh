#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="sql_execution_${timestamp}.csv"
filename="top_execnt.csv"

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

COL exec FORMAT 9999999
COL rowp FORMAT 999999999
COL avg_rowp_per_exec FORMAT 999999.9999
COL avg_cput_secs FORMAT 999999.9999
COL avg_elap_secs FORMAT 999999.9999
COL sql_id FORMAT a20
COL module_info FORMAT a30
COL sql_text FORMAT a300

SPOOL $filename

SELECT *
  FROM (SELECT sqt.exec,
               sqt.rowp,
               DECODE(sqt.exec, 0, TO_NUMBER(NULL), sqt.rowp / sqt.exec) AS avg_rowp_per_exec,
               DECODE(sqt.exec, 0, TO_NUMBER(NULL), sqt.cput / sqt.exec / 1000000) AS avg_cput_secs,
               DECODE(sqt.exec, 0, TO_NUMBER(NULL), sqt.elap / sqt.exec / 1000000) AS avg_elap_secs,
               sqt.sql_id,
               DECODE(sqt.module, NULL, NULL, 'Module: ' || sqt.module) AS module_info,
               '"' || REPLACE(REPLACE(NVL(st.sql_text, '** SQL Text Not Available **'), '"', '""'), CHR(10), ' ') || '"' AS sql_text
          FROM (SELECT sql_id,
                       MAX(module) AS module,
                       SUM(executions_delta) AS exec,
                       SUM(rows_processed_delta) AS rowp,
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
                 GROUP BY sql_id, dbid) sqt
          LEFT JOIN dba_hist_sqltext st
            ON st.sql_id = sqt.sql_id
           AND st.dbid = sqt.dbid
         WHERE sqt.exec > 0
         ORDER BY NVL(sqt.exec, -1) DESC, sqt.sql_id)
 WHERE ROWNUM < 21
   AND (ROWNUM <= 10 OR
        (100 * exec) /
        (SELECT SUM(e.VALUE) - SUM(b.value) AS total_exec_count
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
            AND e.stat_name = 'execute count'
            AND b.stat_name = 'execute count') > 1);

SPOOL OFF
EOF

