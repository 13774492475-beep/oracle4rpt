#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
filename="asm_diskgroup_use_pct.csv"

sqlplus -s "/ as sysdba" <<EOF > /dev/null

SET TERMOUT OFF
SET ECHO OFF
SET FEEDBACK OFF
SET HEADING ON        
SET UNDERLINE OFF     
SET PAGESIZE 1000     
SET NEWPAGE NONE      
SET LINESIZE 1000      
SET TRIMSPOOL ON      
SET TRIMOUT ON        
SET COLSEP ','        
SET TIMING OFF

# Adjusting column formats to prevent overflow and wrapping
COLUMN NAME FORMAT A30
COLUMN AU_SIZE_MB FORMAT 999999990D99
COLUMN STATE FORMAT A15
COLUMN TYPE FORMAT A20
COLUMN TOTAL_DISK_SIZE_MB FORMAT 999999999
COLUMN DG_TOTAL_MB FORMAT 999999999
COLUMN DG_FREE_MB FORMAT 999999999
COLUMN DG_USED_PCT FORMAT 999.99
COLUMN OFFLINE_DISKS FORMAT 999999999
COLUMN REDUNDANCY FORMAT A20

SPOOL $filename

SELECT
    dg.name AS "NAME",
    dg.allocation_unit_size / (1024 * 1024) AS "AU_SIZE_MB",
    dg.state AS "STATE",
    dg.type AS "TYPE",
    dg.total_mb AS "TOTAL_DISK_SIZE_MB",
    dg.total_mb AS "DG_TOTAL_MB",
    dg.free_mb AS "DG_FREE_MB",
    ROUND(((dg.total_mb - dg.free_mb) / dg.total_mb) * 100, 2) AS "DG_USED_PCT",
    (SELECT COUNT(*) FROM v\$asm_disk d WHERE d.group_number = dg.group_number AND d.mount_status = 'CLOSED') AS "OFFLINE_DISKS",
    dg.type AS "REDUNDANCY"
FROM
    v\$asm_diskgroup dg
ORDER BY
    dg.name;

SPOOL OFF
EOF
