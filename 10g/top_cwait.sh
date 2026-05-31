#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="sql_clwait_analysis_${timestamp}.csv"
filename="top_cwait.csv"

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

COL clwait_secs FORMAT 999999.9999
COL clwait_pct FORMAT 999999.99
COL elap_secs FORMAT 999999.9999
COL cput_secs FORMAT 999999.9999
COL exec FORMAT 9999999
COL sql_id FORMAT a20
COL module_info FORMAT a30
COL sql_text FORMAT a300

SPOOL $filename

SELECT *
  FROM (SELECT 
               sqt.clwait / 1000000 AS clwait_secs,
               DECODE(sqt.elap, 0, sqt.clwait, 100 * sqt.clwait / sqt.elap) AS clwait_pct,
               sqt.elap / 1000000 AS elap_secs,
               sqt.cput / 1000000 AS cput_secs,
               sqt.exec,
               sqt.sql_id,
               DECODE(sqt.module, NULL, NULL, 'Module: ' || sqt.module) AS module_info,
               '"' || REPLACE(REPLACE(NVL(st.sql_text, '** SQL Text Not Available **'), '"', '""'), CHR(10), ' ') || '"' AS sql_text
          FROM (SELECT sql_id, MAX(module) AS module,
                       SUM(executions_delta) AS exec, 
                       SUM(cpu_time_delta) AS cput, 
                       SUM(elapsed_time_delta) AS elap,
                       SUM(clwait_delta) AS clwait,
                       dbid
                  FROM dba_hist_sqlstat
                 WHERE dbid = (SELECT dbid FROM v\$database)
                   AND instance_number = (SELECT instance_number FROM v\$instance)
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
         WHERE sqt.clwait > 5000
         ORDER BY NVL(sqt.clwait, -1) DESC, sqt.sql_id)
 WHERE ROWNUM < 21;

SPOOL OFF
EOF

