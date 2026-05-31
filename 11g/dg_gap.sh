#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="dg_gap_${timestamp}.csv"
filename="dg_gap.csv"

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

COLUMN AArownum FORMAT 99999
COLUMN thread# FORMAT 9999
COLUMN SEQUENCE# FORMAT 999999
COLUMN FIRST_TIME FORMAT A19
COLUMN NEXT_TIME FORMAT A19
COLUMN DB_UNIQUE_NAME FORMAT A30
COLUMN database_role FORMAT A10
COLUMN APPLIED FORMAT A10

SPOOL $filename
select  ROWNUM AS AArownum,thread#,SEQUENCE#,FIRST_TIME,NEXT_TIME,DB_UNIQUE_NAME,database_role,APPLIED   FROM (
                                 SELECT
    a.thread#,
    a.SEQUENCE#,
    TO_CHAR(a.FIRST_TIME, 'yyyy-mm-dd hh24:mi:ss') AS FIRST_TIME,
    TO_CHAR(a.NEXT_TIME, 'yyyy-mm-dd hh24:mi:ss') AS NEXT_TIME,
    b.DB_UNIQUE_NAME,'PRIMARY' as database_role,
                '' as APPLIED
FROM
    (SELECT
        SEQUENCE#,
        FIRST_TIME,
        NEXT_TIME,
        thread#,
        dest_id,
        MAX(SEQUENCE#) OVER (PARTITION BY thread#) max_data
     FROM
        v\$ARCHIVED_LOG
     WHERE
        dest_id IN (SELECT dest_id FROM v\$archive_dest WHERE target = 'PRIMARY' and STATUS='VALID')
    ) a
JOIN
    v\$ARCHIVE_DEST_STATUS b ON a.dest_id = b.DEST_ID
WHERE
    a.SEQUENCE# = a.max_data
union all
SELECT
    a.thread#,
    a.SEQUENCE#,
    TO_CHAR(a.FIRST_TIME, 'yyyy-mm-dd hh24:mi:ss') AS FIRST_TIME,
    TO_CHAR(a.NEXT_TIME, 'yyyy-mm-dd hh24:mi:ss') AS NEXT_TIME,
    b.DB_UNIQUE_NAME,'STANDBY' as database_role,
    a.APPLIED
FROM
    (SELECT
        SEQUENCE#,
        FIRST_TIME,
        NEXT_TIME,
        APPLIED,
        thread#,
        dest_id,
        MAX(SEQUENCE#) OVER (PARTITION BY thread#) max_data
     FROM
        v\$ARCHIVED_LOG
     WHERE
        APPLIED != 'NO'
        AND dest_id IN (SELECT dest_id FROM v\$archive_dest WHERE target = 'STANDBY' and STATUS='VALID')
    ) a
JOIN
    v\$ARCHIVE_DEST_STATUS b ON a.dest_id = b.DEST_ID
WHERE
    a.SEQUENCE# = a.max_data);

SPOOL OFF
EOF
