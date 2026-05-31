#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="top_bufget_${timestamp}.csv"
filename="top_bufget.csv"

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

COL Sql_Id FORMAT a20
COL Plan_Hash_Value FORMAT 999999999999999999
COL Total_Buffer_Gets FORMAT 999999999
COL Total_Executions FORMAT 9999
COL Buffer_Get_Onetime FORMAT 999999.9999
COL Start_Time FORMAT a19
COL End_Time FORMAT a19
COL SQL_Text FORMAT a300

SPOOL $filename

WITH TopLogicalReads AS (
    SELECT
        sqt.sql_id,
        sqt.plan_hash_value,
        SUM(sqt.buffer_gets_delta) AS Total_Buffer_Gets,
        SUM(sqt.executions_delta) AS Total_Executions,
        DECODE(SUM(sqt.executions_delta), 0, TO_NUMBER(NULL), 
               (SUM(sqt.buffer_gets_delta) / SUM(sqt.executions_delta))) AS Buffer_Get_Onetime,
        MIN(snap.BEGIN_INTERVAL_TIME) AS Start_Time,
        MAX(snap.END_INTERVAL_TIME) AS End_Time
    FROM
        dba_hist_sqlstat sqt
    JOIN
        dba_hist_snapshot snap ON sqt.snap_id = snap.snap_id AND sqt.instance_number = snap.instance_number
    WHERE
        snap.snap_id >= (SELECT MAX(snap_id) - 7 FROM dba_hist_snapshot)
        AND snap.snap_id <= (SELECT MAX(snap_id) FROM dba_hist_snapshot)
    GROUP BY
        sqt.sql_id, sqt.plan_hash_value
    HAVING
        DECODE(SUM(sqt.executions_delta), 0, TO_NUMBER(NULL), 
               (SUM(sqt.buffer_gets_delta) / SUM(sqt.executions_delta))) > 1000
),
RankedResults AS (
    SELECT
        ts.sql_id,
        ts.plan_hash_value,
        ts.Total_Buffer_Gets,
        ts.Total_Executions,
        ts.Buffer_Get_Onetime,
        ts.Start_Time,
        ts.End_Time,
        ROW_NUMBER() OVER (PARTITION BY ts.sql_id ORDER BY ts.Total_Buffer_Gets DESC) AS rn
    FROM
        TopLogicalReads ts
    JOIN
        dba_hist_sql_plan pl ON ts.sql_id = pl.sql_id AND ts.plan_hash_value = pl.plan_hash_value
    WHERE
        pl.operation = 'TABLE ACCESS' AND pl.options = 'FULL'
)
SELECT
    "Sql_Id",
    "Plan_Hash_Value",
    Total_Buffer_Gets,
    Total_Executions,
    Buffer_Get_Onetime,
    "Start Time",
    "End Time",
    SQL_Text
FROM (
    SELECT
        rr.sql_id AS "Sql_Id",
        rr.plan_hash_value AS "Plan_Hash_Value",
        rr.Total_Buffer_Gets,
        rr.Total_Executions,
        rr.Buffer_Get_Onetime,
        TO_CHAR(rr.Start_Time, 'YYYY-MM-DD HH24:MI:SS') AS "Start Time",
        TO_CHAR(rr.End_Time, 'YYYY-MM-DD HH24:MI:SS') AS "End Time",
        -- Format SQL Text with line breaks replaced by a space and enclose it in double quotes
        '"' || REPLACE(REPLACE(NVL(st.sql_text, ' ** SQL Text Not Available ** '), '"', '""'), CHR(10), ' ') || '"' AS SQL_Text,
        ROWNUM AS rnum
    FROM
        RankedResults rr
    LEFT JOIN
        dba_hist_sqltext st ON st.sql_id = rr.sql_id
    WHERE
        rr.rn = 1
    ORDER BY
        rr.Total_Buffer_Gets DESC
)
WHERE rnum <= 20;
    
SPOOL OFF
EOF


