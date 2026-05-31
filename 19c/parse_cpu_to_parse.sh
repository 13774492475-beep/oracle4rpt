#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="parse_cpu_to_parse_${timestamp}.csv"
filename="parse_cpu_to_parse.csv"

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
parse_time_stats AS (
    SELECT 
        snap_id,
        SUM(CASE WHEN stat_name = 'parse time cpu' THEN value ELSE 0 END) AS cpu_time,
        SUM(CASE WHEN stat_name = 'parse time elapsed' THEN value ELSE 0 END) AS elapsed_time
    FROM 
        DBA_HIST_SYSSTAT
    WHERE 
        dbid = (SELECT dbid FROM current_db)
        AND instance_number = (SELECT instance_number FROM current_db)
        AND snap_id BETWEEN (SELECT beg_snap FROM snapshot_range) AND (SELECT end_snap FROM snapshot_range)
        AND stat_name IN ('parse time cpu', 'parse time elapsed')
    GROUP BY 
        snap_id
),
start_end_values AS (
    SELECT 
        MIN(snap_id) AS start_snap,
        MAX(snap_id) AS end_snap
    FROM 
        parse_time_stats
)
SELECT 
    ROUND(
        100 * (
            (SUM(CASE WHEN snap_id = (SELECT end_snap FROM start_end_values) THEN cpu_time ELSE 0 END) - 
             SUM(CASE WHEN snap_id = (SELECT start_snap FROM start_end_values) THEN cpu_time ELSE 0 END)) /
            NULLIF(
                (SUM(CASE WHEN snap_id = (SELECT end_snap FROM start_end_values) THEN elapsed_time ELSE 0 END) - 
                 SUM(CASE WHEN snap_id = (SELECT start_snap FROM start_end_values) THEN elapsed_time ELSE 0 END)), 
                0
            )
        ),
        2
    ) AS "ParseCPUtoElapsedRatio%"
FROM 
    parse_time_stats;


SPOOL OFF
EOF
