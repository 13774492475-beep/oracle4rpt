#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="invi_cons_${timestamp}.csv"
filename="invi_cons.csv"

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
    owner AS "Owner",
    constraint_name AS "Constraint Name",
    constraint_type AS "Constraint Type",
    table_name AS "Table Name",
    search_condition AS "Search Condition",
    status AS "Status"
FROM
    dba_constraints
WHERE
    status = 'DISABLED'
    AND owner NOT IN (
        'SYS', 'SYSTEM', 'OLAPSYS', 'OUTLN', 'ORDDATA', 'ORDPLUGINS',
        'MDSYS', 'CTXSYS', 'WMSYS', 'XDB', 'APPQOSSYS', 'DBSNMP',
        'SYSMAN', 'MGMT_VIEW', 'OJVMSYS', 'AUDSYS', 'DVSYS', 'GGSYS', 'LBACSYS',
        'ANONYMOUS', 'ORDSYS', 'SI_INFORMTN_SCHEMA', 'PERFSTAT', 'MDDATA',
        'TSMSYS', 'DIP', 'EXFSYS', 'DMSYS', 'ORDDATA', 'SPATIAL_CSW_ADMIN_USR',
        'SPATIAL_WFS_ADMIN_USR', 'FLOWS_FILES', 'GSMADMIN_INTERNAL',
        'REMOTE_SCHEDULER_AGENT', 'DBSFWUSER', 'AURORA$JIS$UTILITY$', 
        'OSE$HTTP$ADMIN', 'WEBSYS', 'WKPROXY', 'SYS$UMF', 'AUDSYS',
        'C##YUNQU', 'SYSBACKUP', 'GSMUSER', 'C##CPR', 'SYSRAC',
        'C##YS', 'SYSKM', 'C##TEST', 'SYSDG', 'GSMROOTUSER', 'C##CPR123'
    )
ORDER BY
    table_name, constraint_name;

SPOOL OFF
EOF
