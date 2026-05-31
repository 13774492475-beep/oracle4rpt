#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="sql_version_count_${timestamp}.csv"
filename="top_vcnt.csv"

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

COL version_count FORMAT 999999
COL exec FORMAT 9999999
COL sql_id FORMAT a20
COL module_info FORMAT a30
COL sql_text FORMAT a300

SPOOL $filename

SELECT *
  FROM (SELECT /*+ ordered use_nl (b st) */
               e.version_count,
               sqt.exec,
               e.sql_id,
               DECODE(e.module, NULL, NULL, 'Module: ' || e.module) AS module_info,
               '"' || REPLACE(REPLACE(NVL(st.sql_text, '** SQL Text Not Available **'), '"', '""'), CHR(10), ' ') || '"' AS sql_text
          FROM dba_hist_sqlstat e
          LEFT JOIN (SELECT sql_id, SUM(executions_delta) AS exec
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
                     GROUP BY sql_id) sqt
            ON sqt.sql_id = e.sql_id
          LEFT JOIN dba_hist_sqltext st 
            ON st.sql_id = e.sql_id
           AND st.dbid = e.dbid
         WHERE e.snap_id = (SELECT MAX(snap_id)
                             FROM dba_hist_snapshot
                            WHERE TRUNC(end_interval_time) = TRUNC(SYSDATE)
                              AND instance_number = (SELECT instance_number FROM v\$instance))
           AND e.dbid = (SELECT dbid FROM v\$database)
           AND e.instance_number = (SELECT instance_number FROM v\$instance)
           AND e.version_count > 20
         ORDER BY NVL(e.version_count, -1) DESC, e.sql_id)
 WHERE ROWNUM < 21;

SPOOL OFF
EOF

