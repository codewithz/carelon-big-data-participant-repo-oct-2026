-- Challenge 9D: one row per queue per day per hour, and proof that it adds up.
-- Run in pgAdmin after Lab 9C.

-- Step 2: the hourly view. The same counts as kpi_queue_daily, one level finer.
CREATE OR REPLACE VIEW reporting.kpi_queue_hourly AS
SELECT i.queue_id,
       i.contact_date,
       extract(hour FROM i.arrived_at AT TIME ZONE 'Asia/Manila')::int        AS hour,
       count(*)                                                                AS reached,
       count(*) FILTER (WHERE i.outcome = 'abandoned' AND i.wait_sec <= 5)     AS short_abandons,
       count(*) FILTER (WHERE NOT (i.outcome = 'abandoned' AND i.wait_sec <= 5)) AS offered,
       count(*) FILTER (WHERE i.outcome = 'abandoned' AND i.wait_sec > 5)      AS abandoned,
       count(*) FILTER (WHERE i.outcome = 'answered')                          AS answered,
       count(*) FILTER (WHERE i.outcome = 'answered'
                          AND i.wait_sec <= q.sl_threshold_sec)                AS answered_in_sl,
       count(*) FILTER (WHERE i.outcome = 'abandoned'
                          AND i.wait_sec > q.sl_threshold_sec)                 AS abandoned_after_sl,
       coalesce(sum(i.handle_sec) FILTER (WHERE i.outcome = 'answered'), 0)    AS handle_sec_total
FROM reporting.interactions i
JOIN src.queues q ON q.queue_id = i.queue_id
WHERE i.channel IN ('voice', 'chat')
GROUP BY i.queue_id, i.contact_date, extract(hour FROM i.arrived_at AT TIME ZONE 'Asia/Manila');

-- Step 3: size
SELECT count(*) AS rows, min(hour) AS first_hour, max(hour) AS last_hour
FROM reporting.kpi_queue_hourly;

-- Step 4: reconcile. Add the hours up to days and compare with the daily view, both ways.
WITH from_hours AS (
    SELECT queue_id, contact_date,
           sum(reached) AS reached, sum(short_abandons) AS short_abandons, sum(offered) AS offered,
           sum(abandoned) AS abandoned, sum(answered) AS answered, sum(answered_in_sl) AS answered_in_sl,
           sum(abandoned_after_sl) AS abandoned_after_sl, sum(handle_sec_total) AS handle_sec_total
    FROM reporting.kpi_queue_hourly
    GROUP BY queue_id, contact_date
)
SELECT (SELECT count(*) FROM (SELECT * FROM from_hours
                              EXCEPT ALL SELECT * FROM reporting.kpi_queue_daily) a) AS only_in_hours,
       (SELECT count(*) FROM (SELECT * FROM reporting.kpi_queue_daily
                              EXCEPT ALL SELECT * FROM from_hours) b) AS only_in_days;

-- Step 5: the worst hours of the month for voice service level
SELECT k.hour,
       sum(k.offered) AS offered,
       round(100.0 * sum(k.answered_in_sl) / sum(k.answered + k.abandoned_after_sl), 1) AS service_level_pct
FROM reporting.kpi_queue_hourly k
JOIN reporting.dim_queue q ON q.queue_id = k.queue_id
WHERE q.channel = 'voice'
GROUP BY k.hour
ORDER BY service_level_pct
LIMIT 3;
