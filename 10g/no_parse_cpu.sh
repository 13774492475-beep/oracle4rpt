#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="no_parse_cpu_${timestamp}.csv"
filename="no_parse_cpu.csv"

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
parse_cpu_time AS (
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
        AND s.stat_name = 'parse time cpu'
),
db_cpu_time AS (
    SELECT 
        SUM(CASE WHEN s.snap_id = r.end_snap THEN value ELSE 0 END) AS end_value,
        SUM(CASE WHEN s.snap_id = r.beg_snap THEN value ELSE 0 END) AS start_value
    FROM 
        DBA_HIST_SYS_TIME_MODEL s
    JOIN 
        snapshot_range r ON s.snap_id BETWEEN r.beg_snap AND r.end_snap
    WHERE 
        s.dbid = (SELECT dbid FROM current_db)
        AND s.instance_number = (SELECT instance_number FROM current_db)
        AND s.stat_name = 'DB CPU'
)
SELECT 
    ROUND(
        100 * (
            1 - (
                (pc.end_value - pc.start_value) / 
                NULLIF((dc.end_value - dc.start_value) / 10000, 0)
            )
        ),
        2
    ) AS "Parse Time CPU % of DB CPU"
FROM 
    parse_cpu_time pc, db_cpu_time dc;

SPOOL OFF
EOF
