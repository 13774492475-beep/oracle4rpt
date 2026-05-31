#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="buf_nowait_${timestamp}.csv"
filename="buf_nowait.csv"

sqlplus -s "/ as sysdba" <<EOF > /dev/null

SET TERMOUT OFF
SET ECHO OFF
SET FEEDBACK OFF
SET HEADING ON        
SET UNDERLINE OFF     
SET PAGESIZE 1000     
SET NEWPAGE NONE      
SET LINESIZE 500      
SET TRIMSPOOL ON      
SET TRIMOUT ON        
SET COLSEP ','        
SET TIMING OFF

SPOOL $filename

WITH current_db AS (
    SELECT 
        dbid,
        instance_number
    FROM 
        v\$database, v\$instance
),
snapshot_range AS (
    SELECT 
        MIN(snap_id) AS beg_snap,
        MAX(snap_id) AS end_snap
    FROM 
        DBA_HIST_SNAPSHOT
    WHERE 
        end_interval_time BETWEEN TRUNC(SYSDATE) - 7 AND SYSDATE
        AND dbid = (SELECT dbid FROM current_db)
        AND instance_number = (SELECT instance_number FROM current_db)
),
buffer_nowait AS (
    SELECT 
        ROUND(
            100 * (
                1 - (
                    (SELECT SUM(wait_count) FROM DBA_HIST_WAITSTAT w 
                     WHERE w.snap_id = (SELECT end_snap FROM snapshot_range) 
                     AND w.dbid = (SELECT dbid FROM current_db) 
                     AND w.instance_number = (SELECT instance_number FROM current_db)
                    ) - 
                    (SELECT SUM(wait_count) FROM DBA_HIST_WAITSTAT w 
                     WHERE w.snap_id = (SELECT beg_snap FROM snapshot_range) 
                     AND w.dbid = (SELECT dbid FROM current_db) 
                     AND w.instance_number = (SELECT instance_number FROM current_db)
                    )
                ) /
                NULLIF(
                    (SELECT SUM(value) FROM DBA_HIST_SYSSTAT e 
                     WHERE e.snap_id = (SELECT end_snap FROM snapshot_range) 
                     AND e.dbid = (SELECT dbid FROM current_db) 
                     AND e.instance_number = (SELECT instance_number FROM current_db)
                     AND e.stat_name = 'session logical reads'
                    ) - 
                    (SELECT SUM(value) FROM DBA_HIST_SYSSTAT b 
                     WHERE b.snap_id = (SELECT beg_snap FROM snapshot_range) 
                     AND b.dbid = (SELECT dbid FROM current_db) 
                     AND b.instance_number = (SELECT instance_number FROM current_db)
                     AND b.stat_name = 'session logical reads'
                    ),
                    0
                )
            ),
            2
        ) AS "Buffer No Wait%"
    FROM dual
)
SELECT * FROM buffer_nowait;

	
SPOOL OFF
EOF
