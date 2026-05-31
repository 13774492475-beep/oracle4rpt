#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="cursor_use_${timestamp}.csv"
filename="cursor_use.csv"

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

COLUMN "Instance ID" FORMAT 999999
COLUMN "Session SID" FORMAT 999999
COLUMN "Serial#" FORMAT 999999
COLUMN "Open Cursors" FORMAT 999999  
COLUMN "Session Cursor Limit" FORMAT A20 
COLUMN "Cursors Usage (%)" FORMAT 999999.99

SPOOL $filename

SELECT *
FROM (
    SELECT
        s.inst_id AS "Instance ID",
        s.sid AS "Session SID",
        s.serial# AS "Serial#",
        COUNT(DISTINCT o.address) AS "Open Cursors",  -- Count distinct cursor addresses
        p.value AS "Session Cursor Limit",
        ROUND((COUNT(DISTINCT o.address) / p.value) * 100, 2) AS "Cursors Usage (%)"
    FROM
        gv\$open_cursor o
    JOIN
        gv\$session s ON o.sid = s.sid AND o.inst_id = s.inst_id
    JOIN
        gv\$parameter p ON p.name = 'open_cursors'
    WHERE
        s.status = 'ACTIVE'
    GROUP BY
        s.inst_id, s.sid, s.serial#, p.value
    ORDER BY
        "Cursors Usage (%)" DESC
)
WHERE ROWNUM <= 10;
	
SPOOL OFF
EOF
