#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="asm_disk_info_${timestamp}.csv"
filename="asm_disk_info.csv"

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

COLUMN Group_Number FORMAT 9999999999
COLUMN Diskgroupname FORMAT A30
COLUMN Namedisk FORMAT A30
COLUMN Path FORMAT A50
COLUMN State FORMAT A15
COLUMN Total_Mb FORMAT 9999999999
COLUMN Os_Mb FORMAT 9999999999

SPOOL $filename

SELECT
    d.group_number AS "Group_Number",
    g.name AS "Diskgroupname",
    d.name AS "Namedisk",
    d.path AS "Path",
    d.state AS "State",
    d.total_mb AS "Total_Mb",
    d.os_mb AS "Os_Mb"
FROM
    v\$asm_disk d
JOIN
    v\$asm_diskgroup g ON d.group_number = g.group_number
ORDER BY
    d.group_number, d.name;

SPOOL OFF
EOF

