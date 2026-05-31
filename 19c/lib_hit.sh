#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="lib_hit_${timestamp}.csv"
filename="lib_hit.csv"

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
)
SELECT 
    ROUND(
        100 * (SUM(e.PINHITS) - SUM(b.pinhits)) /
        NULLIF(SUM(e.PINS) - SUM(b.pins), 0),
        2
    ) AS LibraryHitRatio
FROM 
    DBA_HIST_LIBRARYCACHE b
JOIN 
    DBA_HIST_LIBRARYCACHE e ON e.SNAP_ID = (SELECT end_snap FROM snapshot_range)
    AND e.DBID = (SELECT dbid FROM current_db)
    AND e.INSTANCE_NUMBER = (SELECT instance_number FROM current_db)
WHERE 
    b.SNAP_ID = (SELECT beg_snap FROM snapshot_range)
    AND b.DBID = (SELECT dbid FROM current_db)
    AND b.INSTANCE_NUMBER = (SELECT instance_number FROM current_db);

SPOOL OFF

EXIT
EOF

