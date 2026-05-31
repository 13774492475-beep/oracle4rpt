#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="soft_parse_${timestamp}.csv"
filename="soft_parse.csv"

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
parse_stats AS (
    SELECT 
        snap_id,
        SUM(CASE WHEN stat_name = 'parse count (hard)' THEN value ELSE 0 END) AS hard_parse_count,
        SUM(CASE WHEN stat_name = 'parse count (total)' THEN value ELSE 0 END) AS total_parse_count
    FROM 
        DBA_HIST_SYSSTAT
    WHERE 
        dbid = (SELECT dbid FROM current_db)
        AND instance_number = (SELECT instance_number FROM current_db)
        AND snap_id BETWEEN (SELECT beg_snap FROM snapshot_range) AND (SELECT end_snap FROM snapshot_range)
        AND stat_name IN ('parse count (hard)', 'parse count (total)')
    GROUP BY 
        snap_id
),
start_end_values AS (
    SELECT 
        MIN(snap_id) AS start_snap,
        MAX(snap_id) AS end_snap
    FROM 
        parse_stats
)
SELECT 
    ROUND(
        100 * (
            1 - (
                (SUM(CASE WHEN snap_id = (SELECT end_snap FROM start_end_values) THEN hard_parse_count ELSE 0 END) - 
                 SUM(CASE WHEN snap_id = (SELECT start_snap FROM start_end_values) THEN hard_parse_count ELSE 0 END)) /
                NULLIF(
                    (SUM(CASE WHEN snap_id = (SELECT end_snap FROM start_end_values) THEN total_parse_count ELSE 0 END) - 
                     SUM(CASE WHEN snap_id = (SELECT start_snap FROM start_end_values) THEN total_parse_count ELSE 0 END)), 
                    0
                )
            )
        ),
        2
    ) AS "Parse Efficiency%"
FROM 
    parse_stats;


SPOOL OFF
EOF
