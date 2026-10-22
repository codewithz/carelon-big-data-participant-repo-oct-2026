-- Lab 3E: every query, in order. Part 1 and the hand calculations are on paper; see the lab for the practice-table queries.
SELECT count(*) AS rows_in_table, count(DISTINCT call_id) AS distinct_calls FROM src.calls;
CREATE OR REPLACE VIEW reporting.calls_clean AS
SELECT DISTINCT c.*, q.queue_name, q.sl_threshold_sec,
       (c.arrived_at AT TIME ZONE 'Asia/Manila')::date AS call_date
FROM src.calls c
JOIN src.queues q USING (queue_id);
SELECT count(*) FROM reporting.calls_clean;
SELECT queue_name,
       count(*) AS offered,
       count(*) FILTER (WHERE outcome = 'answered') AS answered,
       count(*) FILTER (WHERE outcome = 'abandoned') AS abandoned
FROM reporting.calls_clean
WHERE call_date = '2026-10-01'
GROUP BY queue_name
ORDER BY queue_name;
SELECT queue_name,
       count(*) AS offered,
       round(100.0 * count(*) FILTER (WHERE outcome = 'abandoned') / count(*), 1) AS abandonment_pct,
       round(avg(talk_sec + hold_sec + wrap_sec) FILTER (WHERE outcome = 'answered')) AS aht_sec,
       round(100.0 * count(*) FILTER (WHERE outcome = 'answered' AND wait_sec <= sl_threshold_sec)
             / count(*) FILTER (WHERE outcome = 'answered' OR wait_sec > sl_threshold_sec), 1) AS service_level_pct
FROM reporting.calls_clean
WHERE call_date = '2026-10-01'
  AND NOT (outcome = 'abandoned' AND wait_sec <= 5)
GROUP BY queue_name
ORDER BY queue_name;
SELECT q.queue_name,
       count(*) AS offered,
       count(*) FILTER (WHERE c.outcome = 'abandoned') AS abandoned,
       round(100.0 * count(*) FILTER (WHERE c.outcome = 'abandoned') / count(*), 1) AS abandonment_pct
FROM practice.calls c JOIN practice.queues q ON q.queue_id = c.queue_id
WHERE NOT (c.outcome = 'abandoned' AND c.wait_sec <= 5)
GROUP BY q.queue_name ORDER BY q.queue_name;
SELECT q.queue_name, round(avg(c.talk_sec + c.hold_sec + c.wrap_sec)) AS aht_sec
FROM practice.calls c JOIN practice.queues q ON q.queue_id = c.queue_id
WHERE c.outcome = 'answered' GROUP BY q.queue_name ORDER BY q.queue_name;
SELECT q.queue_name,
       count(*) FILTER (WHERE c.outcome = 'answered' AND c.wait_sec <= q.sl_threshold_sec) AS answered_in_time,
       count(*) FILTER (WHERE c.outcome = 'answered' OR c.wait_sec > q.sl_threshold_sec) AS counted,
       round(100.0 * count(*) FILTER (WHERE c.outcome = 'answered' AND c.wait_sec <= q.sl_threshold_sec)
        / count(*) FILTER (WHERE c.outcome = 'answered' OR c.wait_sec > q.sl_threshold_sec), 1) AS service_level_pct
FROM practice.calls c JOIN practice.queues q ON q.queue_id = c.queue_id
WHERE NOT (c.outcome = 'abandoned' AND c.wait_sec <= 5)
GROUP BY q.queue_name ORDER BY q.queue_name;
