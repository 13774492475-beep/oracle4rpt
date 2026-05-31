#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="redo_switch_${timestamp}.csv"
filename="redo_switch.csv"

sqlplus -s "/ as sysdba" <<EOF > /dev/null

SET TERMOUT OFF
SET ECHO OFF
SET FEEDBACK OFF
SET HEADING ON        
SET UNDERLINE OFF     
SET PAGESIZE 1000     
SET NEWPAGE NONE      
SET LINESIZE 1800     
SET TRIMSPOOL ON      
SET TRIMOUT ON        
SET COLSEP ','        
SET TIMING OFF

SPOOL $filename

SELECT
    TO_CHAR(first_time, 'YYYY-MM-DD') AS "Day",
    SUM(CASE WHEN TO_CHAR(first_time, 'HH24') = '00' THEN 1 ELSE 0 END) AS "H00",
    SUM(CASE WHEN TO_CHAR(first_time, 'HH24') = '01' THEN 1 ELSE 0 END) AS "H01",
    SUM(CASE WHEN TO_CHAR(first_time, 'HH24') = '02' THEN 1 ELSE 0 END) AS "H02",
    SUM(CASE WHEN TO_CHAR(first_time, 'HH24') = '03' THEN 1 ELSE 0 END) AS "H03",
    SUM(CASE WHEN TO_CHAR(first_time, 'HH24') = '04' THEN 1 ELSE 0 END) AS "H04",
    SUM(CASE WHEN TO_CHAR(first_time, 'HH24') = '05' THEN 1 ELSE 0 END) AS "H05",
    SUM(CASE WHEN TO_CHAR(first_time, 'HH24') = '06' THEN 1 ELSE 0 END) AS "H06",
    SUM(CASE WHEN TO_CHAR(first_time, 'HH24') = '07' THEN 1 ELSE 0 END) AS "H07",
    SUM(CASE WHEN TO_CHAR(first_time, 'HH24') = '08' THEN 1 ELSE 0 END) AS "H08",
    SUM(CASE WHEN TO_CHAR(first_time, 'HH24') = '09' THEN 1 ELSE 0 END) AS "H09",
    SUM(CASE WHEN TO_CHAR(first_time, 'HH24') = '10' THEN 1 ELSE 0 END) AS "H10",
    SUM(CASE WHEN TO_CHAR(first_time, 'HH24') = '11' THEN 1 ELSE 0 END) AS "H11",
    SUM(CASE WHEN TO_CHAR(first_time, 'HH24') = '12' THEN 1 ELSE 0 END) AS "H12",
    SUM(CASE WHEN TO_CHAR(first_time, 'HH24') = '13' THEN 1 ELSE 0 END) AS "H13",
    SUM(CASE WHEN TO_CHAR(first_time, 'HH24') = '14' THEN 1 ELSE 0 END) AS "H14",
    SUM(CASE WHEN TO_CHAR(first_time, 'HH24') = '15' THEN 1 ELSE 0 END) AS "H15",
    SUM(CASE WHEN TO_CHAR(first_time, 'HH24') = '16' THEN 1 ELSE 0 END) AS "H16",
    SUM(CASE WHEN TO_CHAR(first_time, 'HH24') = '17' THEN 1 ELSE 0 END) AS "H17",
    SUM(CASE WHEN TO_CHAR(first_time, 'HH24') = '18' THEN 1 ELSE 0 END) AS "H18",
    SUM(CASE WHEN TO_CHAR(first_time, 'HH24') = '19' THEN 1 ELSE 0 END) AS "H19",
    SUM(CASE WHEN TO_CHAR(first_time, 'HH24') = '20' THEN 1 ELSE 0 END) AS "H20",
    SUM(CASE WHEN TO_CHAR(first_time, 'HH24') = '21' THEN 1 ELSE 0 END) AS "H21",
    SUM(CASE WHEN TO_CHAR(first_time, 'HH24') = '22' THEN 1 ELSE 0 END) AS "H22",
    SUM(CASE WHEN TO_CHAR(first_time, 'HH24') = '23' THEN 1 ELSE 0 END) AS "H23",
    COUNT(*) AS "Total"
FROM
    v\$log_history
WHERE
    first_time >= TRUNC(SYSDATE) - 7 -- Adjust this range as needed
GROUP BY
    TO_CHAR(first_time, 'YYYY-MM-DD')
ORDER BY
    "Day";

SPOOL OFF
EOF
