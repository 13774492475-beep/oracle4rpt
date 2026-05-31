#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="db_win_sched_${timestamp}.csv"
filename="db_win_sched.csv"

sqlplus -s "/ as sysdba" <<EOF > /dev/null

SET TERMOUT OFF
SET ECHO OFF
SET FEEDBACK OFF
SET HEADING ON        
SET UNDERLINE OFF     
SET PAGESIZE 50000    -- 设置为非常大的值，避免分页
SET LINESIZE 4096     -- 设置为较大的值，确保整行显示      
SET TRIMSPOOL ON      
SET TRIMOUT ON        
SET COLSEP ','        
SET TIMING OFF
SET RECSEP OFF        -- 确保没有额外的记录分隔符
SET NEWPAGE NONE      -- 确保没有额外的新页面字符

COLUMN "Window Name" FORMAT A50  
COLUMN "Resource Plan" FORMAT A30  
COLUMN "Repeat Interval" FORMAT A1000  
COLUMN "Enabled Status" FORMAT A15
COLUMN "Warning" FORMAT A50

SPOOL $filename
SELECT
    window_name AS "Window Name",       
    resource_plan AS "Resource Plan",   
    -- 格式化 Repeat Interval，确保内容保持在一个单元格中
    '"' || REPLACE(REPLACE(NVL(repeat_interval, ' ** Interval Not Available ** '), '"', '""'), CHR(10), ' ') || '"' AS "Repeat Interval",
    enabled AS "Enabled Status",        
    CASE
        WHEN enabled = 'FALSE' THEN 'WARNING: Window Disabled'
        ELSE 'No Warnings'
    END AS "Warning"                    
FROM
    dba_scheduler_windows
WHERE 
    window_name IN ('WEEKNIGHT_WINDOW', 'WEEKEND_WINDOW')
ORDER BY
    window_name;

SPOOL OFF
EOF

