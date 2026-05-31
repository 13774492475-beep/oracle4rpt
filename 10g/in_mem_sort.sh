#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="in_mem_sort_${timestamp}.csv"
filename="in_mem_sort.csv"

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
sorts_memory AS (
    SELECT 
        SUM(CASE WHEN s.snap_id = r.end_snap THEN value ELSE 0 END) AS end_value,
        SUM(CASE WHEN s.snap_id = r.beg_snap THEN value ELSE 0 END) AS start_value
    FROM 
        DBA_HIST_SYSSTAT s
    JOIN 
        snapshot_range r ON s.snap_id BETWEEN r.beg_snap AND r.end_snap
    WHERE 
        s.dbid = (SELECT dbid FROM current_db)
        AND s.instance_number = (SELECT instance_number FROM current_db)
        AND s.stat_name = 'sorts (memory)'
),
sorts_disk AS (
    SELECT 
        SUM(CASE WHEN s.snap_id = r.end_snap THEN value ELSE 0 END) AS end_value,
        SUM(CASE WHEN s.snap_id = r.beg_snap THEN value ELSE 0 END) AS start_value
    FROM 
        DBA_HIST_SYSSTAT s
    JOIN 
        snapshot_range r ON s.snap_id BETWEEN r.beg_snap AND r.end_snap
    WHERE 
        s.dbid = (SELECT dbid FROM current_db)
        AND s.instance_number = (SELECT instance_number FROM current_db)
        AND s.stat_name = 'sorts (disk)'
)
SELECT 
    ROUND(
        100 * (
            (sm.end_value - sm.start_value) / 
            NULLIF(
                (sm.end_value - sm.start_value) + 
                (sd.end_value - sd.start_value), 
                0
            )
        ),
        2
    ) AS "InmemorySort%"
FROM 
    sorts_memory sm, sorts_disk sd
WHERE 
    sm.end_value IS NOT NULL 
    AND sd.end_value IS NOT NULL;

	
SPOOL OFF
EOF
