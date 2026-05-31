#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="redo_nowait_${timestamp}.csv"
filename="redo_nowait.csv"

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
redo_no_wait AS (
    SELECT 
        ROUND(
            100 * (
                1 - (
                    (SELECT SUM(value) FROM DBA_HIST_SYSSTAT e 
                     WHERE e.snap_id = (SELECT end_snap FROM snapshot_range) 
                     AND e.dbid = (SELECT dbid FROM current_db) 
                     AND e.instance_number = (SELECT instance_number FROM current_db)
                     AND e.stat_name = 'redo log space requests'
                    ) - 
                    (SELECT SUM(value) FROM DBA_HIST_SYSSTAT b 
                     WHERE b.snap_id = (SELECT beg_snap FROM snapshot_range) 
                     AND b.dbid = (SELECT dbid FROM current_db) 
                     AND b.instance_number = (SELECT instance_number FROM current_db)
                     AND b.stat_name = 'redo log space requests'
                    )
                ) /
                NULLIF(
                    (SELECT SUM(value) FROM DBA_HIST_SYSSTAT e 
                     WHERE e.snap_id = (SELECT end_snap FROM snapshot_range) 
                     AND e.dbid = (SELECT dbid FROM current_db) 
                     AND e.instance_number = (SELECT instance_number FROM current_db)
                     AND e.stat_name = 'redo entries'
                    ) - 
                    (SELECT SUM(value) FROM DBA_HIST_SYSSTAT b 
                     WHERE b.snap_id = (SELECT beg_snap FROM snapshot_range) 
                     AND b.dbid = (SELECT dbid FROM current_db) 
                     AND b.instance_number = (SELECT instance_number FROM current_db)
                     AND b.stat_name = 'redo entries'
                    ),
                    0
                )
            ),
            2
        ) AS "Redo No Wait%"
    FROM dual
)
SELECT * FROM redo_no_wait;
	
SPOOL OFF
EOF
