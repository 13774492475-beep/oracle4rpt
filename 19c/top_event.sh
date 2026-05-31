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
                         CASE
                           WHEN e.total_waits_fg IS NOT NULL THEN e.total_waits_fg - NVL(b.total_waits_fg, 0)
                           ELSE (e.total_waits - NVL(b.total_waits, 0)) -
                                GREATEST(0, (NVL(ebg.total_waits, 0) - NVL(bbg.total_waits, 0)))
                         END wtfg,
                         CASE
                           WHEN e.total_timeouts_fg IS NOT NULL THEN e.total_timeouts_fg - NVL(b.total_timeouts_fg, 0)
                           ELSE (e.total_timeouts - NVL(b.total_timeouts, 0)) -
                                GREATEST(0, (NVL(ebg.total_timeouts, 0) - NVL(bbg.total_timeouts, 0)))
                         END ttofg,
                         CASE
                           WHEN e.time_waited_micro_fg IS NOT NULL THEN e.time_waited_micro_fg - NVL(b.time_waited_micro_fg, 0)
                           ELSE (e.time_waited_micro - NVL(b.time_waited_micro, 0)) -
                                GREATEST(0, (NVL(ebg.time_waited_micro, 0) - NVL(bbg.time_waited_micro, 0)))
                         END tmfg,
                         e.wait_class wcls
                  FROM dba_hist_system_event b,
                       dba_hist_system_event e,
                       dba_hist_bg_event_summary bbg,
                       dba_hist_bg_event_summary ebg,
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
                    AND bbg.snap_id = miid.snap_id
                    AND ebg.snap_id = maid.snap_id
                    AND e.instance_number = (SELECT instance_number FROM v\$instance)
                    AND e.dbid = b.dbid(+)
                    AND e.instance_number = b.instance_number(+)
                    AND e.event_id = b.event_id(+)
                    AND e.dbid = ebg.dbid(+)
                    AND e.instance_number = ebg.instance_number(+)
                    AND e.event_id = ebg.event_id(+)
                    AND e.dbid = bbg.dbid(+)
                    AND b.dbid = miid.dbid
                    AND e.dbid = maid.dbid
                    AND bbg.dbid = miid.dbid
                    AND ebg.dbid = maid.dbid
                    AND e.instance_number = bbg.instance_number(+)
                    AND e.event_id = bbg.event_id(+)
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
