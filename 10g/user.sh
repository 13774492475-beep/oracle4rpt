#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="user_${timestamp}.csv"
filename="user.csv"

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
set lines 800
col user for a40
col temp_tbs for a40
col user_stats for a40

SPOOL $filename
SELECT
    u.username AS "user",
    u.default_tablespace AS "dft_tbs",
    u.temporary_tablespace AS "temp_tbs",
    TO_CHAR(u.created, 'YYYY-MM-DD HH24:MI:SS') AS "created",         
    TO_CHAR(u.lock_date, 'YYYY-MM-DD HH24:MI:SS') AS "lock_date",     
    TO_CHAR(u.expiry_date, 'YYYY-MM-DD HH24:MI:SS') AS "expire_Date", 
    u.profile AS "Profile",
    u.account_status AS "user_stats",
    CASE
        WHEN p.limit = 'UNLIMITED' THEN 'Yes'
        WHEN p.limit = 'DEFAULT' THEN 'Check Default Profile'
        WHEN TO_NUMBER(p.limit) > 90 THEN 'Yes'
        ELSE 'No'
    END AS "Yesno"
FROM
    dba_users u
JOIN
    dba_profiles p ON u.profile = p.profile
WHERE
    p.resource_name = 'PASSWORD_LIFE_TIME'
    AND u.username NOT IN (
        'CTXSYS', 'SCOTT', 'OUTLN', 'DBSNMP', 'ORDSYS', 'ORDPLUGINS',
        'SI_INFORMTN_SCHEMA', 'MDSYS', 'PERFSTAT', 'MGMT_VIEW', 'MDDATA',
        'OLAPSYS', 'ANONYMOUS', 'ORACLE_OCM', 'TSMSYS', 'DIP', 'WMSYS',
        'EXFSYS', 'DMSYS', 'XDB', 'SYSMAN', 'SYS', 'SYSTEM', 'ORDDATA',
        'APEX_030200', 'FLOWS_FILES', 'GSMADMIN_INTERNAL', 'AUDSYS', 'DVSYS',
        'OJVMSYS', 'LBACSYS', 'WKSYS', 'CPR', 'ODM', 'OE', 'QS_CBADM',
        'QS', 'TRACESVR', 'AURORA\$JIS\$UTILITY\$', 'OSE\$HTTP\$ADMIN', 'WKUSER',
        'WK_TEST', 'REPADMIN', 'DVF', 'ODM_MTR', 'QS_ES', 'QS_WS', 'QS_OS',
        'QS_CB', 'QS_CS', 'QS_ADM', 'APEX_PUBLIC_USER', 'APPQOSSYS',
        'AURORA\$ORB$UNAUTHENTICATED', 'BI', 'FLOWS_040100', 'HR', 'IX',
        'OAS_PUBLIC', 'OWBSYS_AUDIT', 'PM', 'RMAN', 'SH',
        'SPATIAL_CSW_ADMIN_USR', 'SPATIAL_WFS_ADMIN_USR', 'WEBSYS', 'WKPROXY',
        'XS\$NULL', 'SYS\$UMF', 'DBSFWUSER', 'GGSYS', 'GSMCATUSER', 'C##YUNQU',
        'REMOTE_SCHEDULER_AGENT', 'SYSBACKUP', 'GSMUSER', 'C##CPR', 'SYSRAC',
        'C##YS', 'SYSKM', 'C##TEST', 'SYSDG', 'GSMROOTUSER', 'C##CPR123','OWBSYS'
    )
ORDER BY
    u.username;
SPOOL OFF
EOF
