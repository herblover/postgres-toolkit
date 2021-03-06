SELECT pgperf.create_snapshot_pg_stat_bgwriter(0);

SELECT count(*) = 1
  FROM pgperf.snapshot_pg_stat_bgwriter
 WHERE sid = 0
   AND checkpoints_timed >= 0
   AND checkpoints_req >= 0
   AND buffers_checkpoint >= 0
   AND buffers_clean >= 0
   AND maxwritten_clean >= 0
   AND buffers_backend >= 0
   AND buffers_backend_fsync >= 0
   AND buffers_alloc >= 0
   AND stats_reset IS NOT NULL;

CREATE TABLE t1 AS
  SELECT * FROM generate_series(1,1000);
CHECKPOINT;
SELECT pg_sleep(1);

SELECT pgperf.create_snapshot_pg_stat_bgwriter(1);
-- \x
-- SELECT * FROM pgperf.snapshot_pg_stat_bgwriter ORDER BY sid;
-- \x

SELECT b.sid - a.sid = 1,
       b.checkpoints_timed - a.checkpoints_timed = 0,
       b.checkpoints_req - a.checkpoints_req > 0,
       b.buffers_checkpoint - a.buffers_checkpoint > 0,
       b.buffers_clean - a.buffers_clean = 0,
       b.maxwritten_clean - a.maxwritten_clean = 0,
       b.buffers_backend - a.buffers_backend > 0,
       b.buffers_backend_fsync - a.buffers_backend_fsync = 0,
       b.buffers_alloc - a.buffers_alloc > 0,
       b.stats_reset - a.stats_reset = '0'::interval
  FROM ( SELECT * FROM pgperf.snapshot_pg_stat_bgwriter WHERE sid = 0 ) AS a,
       ( SELECT * FROM pgperf.snapshot_pg_stat_bgwriter WHERE sid = 1 ) AS b
;

CREATE TABLE t2 AS
  SELECT * FROM generate_series(1,1000);
CHECKPOINT;

SELECT pgperf.create_snapshot_pg_stat_bgwriter(2);
SELECT count(*) = 3 FROM pgperf.snapshot_pg_stat_bgwriter;

SELECT pgperf.delete_snapshot_pg_stat_bgwriter(1);
SELECT count(*) = 0 FROM pgperf.snapshot_pg_stat_bgwriter WHERE sid = 1;
SELECT count(*) = 2 FROM pgperf.snapshot_pg_stat_bgwriter;

DROP TABLE t1,t2;
