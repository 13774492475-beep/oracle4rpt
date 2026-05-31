#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="top_event_${timestamp}.csv"
filename="top_event.csv"

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

SELECT event "Event",
       waits "Waits",
       ROUND(time, 2) "Time(s)",
       ROUND(avwait, 2) "Avg wait (ms)",
       ROUND(pctwtt, 2) "% DB time",
       wcls "Wait Class"
FROM (SELECT event,
             wtfg waits,
             tmfg / 1000000 time,
             DECODE(wtfg, 0, TO_NUMBER(NULL), tmfg / wtfg) / 1000 avwait,
             DECODE(dbti.dbtime, 0, TO_NUMBER(NULL), tmfg / dbti.dbtime) * 100 pctwtt,
             wcls
      FROM (SELECT event, wtfg, ttofg, tmfg, wcls
            FROM (SELECT e.event_name event,
                         (e.total_waits - NVL(b.total_waits, 0)) wtfg,
                         (e.total_timeouts - NVL(b.total_timeouts, 0)) ttofg,
                         (e.time_waited_micro - NVL(b.time_waited_micro, 0)) tmfg,
                         e.wait_class wcls
                  FROM dba_hist_system_event b,
                       dba_hist_system_event e,
                       (SELECT MIN(snap_id) snap_id, dbid
                        FROM dba_hist_snapshot
                        WHERE TRUNC(begin_interval_time) >= TRUNC(SYSDATE - 7)
                          AND instance_number = (SELECT instance_number FROM v\$instance)
                        GROUP BY dbid) miid,
                       (SELECT MAX(snap_id) snap_id, dbid
                        FROM dba_hist_snapshot
                        WHERE TRUNC(end_interval_time) = TRUNC(SYSDATE)
                          AND instance_number = (SELECT instance_number FROM v\$instance)
                        GROUP BY dbid) maid
                  WHERE b.snap_id = miid.snap_id
                    AND e.snap_id = maid.snap_id
                    AND e.instance_number = (SELECT instance_number FROM v\$instance)
                    AND e.dbid = b.dbid(+)
                    AND e.instance_number = b.instance_number(+)
                    AND e.event_id = b.event_id(+)
                    AND e.total_waits > NVL(b.total_waits, 0)
                    AND e.wait_class <> 'Idle')
            UNION ALL
            SELECT 'DB CPU' event,
                   TO_NUMBER(NULL) wtfg,
                   TO_NUMBER(NULL) ttofg,
                   dbtp.tcpu tmfg,
                   ' ' wcls
            FROM dual,
                 (SELECT SUM(e.VALUE - b.value) AS tcpu
                  FROM dba_hist_sys_time_model b,
                       dba_hist_sys_time_model e
                  WHERE e.dbid = b.dbid
                    AND e.instance_number = b.instance_number
                    AND e.STAT_ID = b.STAT_ID
                    AND b.INSTANCE_NUMBER = (SELECT instance_number FROM v\$instance)
                    AND b.SNAP_ID = (SELECT MIN(snap_id)
                                     FROM dba_hist_snapshot
                                     WHERE TRUNC(begin_interval_time) >= TRUNC(SYSDATE - 7)
                                       AND instance_number = (SELECT instance_number FROM v\$instance))
                    AND e.SNAP_ID = (SELECT MAX(snap_id)
                                     FROM dba_hist_snapshot
                                     WHERE TRUNC(end_interval_time) = TRUNC(SYSDATE)
                                       AND instance_number = (SELECT instance_number FROM v\$instance))
                    AND e.stat_name IN ('DB CPU')) dbtp
            WHERE dbtp.tcpu > 0),
           (SELECT SUM(e.VALUE - b.value) AS dbtime
            FROM dba_hist_sys_time_model b,
                 dba_hist_sys_time_model e
            WHERE e.dbid = b.dbid
              AND e.instance_number = b.instance_number
              AND e.STAT_ID = b.STAT_ID
              AND b.INSTANCE_NUMBER = (SELECT instance_number FROM v\$instance)
              AND b.SNAP_ID = (SELECT MIN(snap_id)
                               FROM dba_hist_snapshot
                               WHERE TRUNC(begin_interval_time) >= TRUNC(SYSDATE - 7)
                                 AND instance_number = (SELECT instance_number FROM v\$instance))
              AND e.SNAP_ID = (SELECT MAX(snap_id)
                               FROM dba_hist_snapshot
                               WHERE TRUNC(end_interval_time) = TRUNC(SYSDATE)
                                 AND instance_number = (SELECT instance_number FROM v\$instance))
              AND e.stat_name IN ('DB time')) dbti
      ORDER BY tmfg DESC, wtfg DESC)
WHERE ROWNUM <= 5;

SPOOL OFF
EOF
