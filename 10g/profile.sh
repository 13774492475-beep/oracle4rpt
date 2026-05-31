#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="profile_${timestamp}.csv"
filename="profile.csv"

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

SELECT
    profile AS "Profile",                
    resource_name AS "Resource_Name",    
    resource_type AS "Resource_Type",    
    limit AS "Limit"                     
FROM
    dba_profiles
WHERE
    resource_name = 'PASSWORD_LIFE_TIME' 
ORDER BY
    profile;
	
SPOOL OFF
EOF
