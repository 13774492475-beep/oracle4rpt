#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="resource_info_${timestamp}.csv"
filename="resource_info.csv"

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
    resource_name AS "Resource_Name",         
    current_utilization AS "Current_Utilization", 
    max_utilization AS "Max_Utilization",     
    initial_allocation AS "Initial_Allocation", 
    limit_value AS "Limit"              
FROM
    v\$resource_limit
ORDER BY
    resource_name;
SPOOL OFF
EOF
