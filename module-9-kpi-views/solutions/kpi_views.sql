-- Module 9 solution: every view from Labs 9A, 9B and 9C.
-- Run in pgAdmin on your own VM, after Lab 8B.
-- Every view is created in the reporting schema, next to reporting.interactions.
-- Safe to run again: CREATE OR REPLACE replaces a view with the same name.

-- ===== Lab 9A: one row per queue per day, counts only =====
CREATE OR REPLACE VIEW reporting.kpi_queue_daily AS
SELECT i.queue_id,
       i.contact_date,
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
GROUP BY i.queue_id, i.contact_date;

-- ===== Lab 9B: the lookup lists and the agent view =====
CREATE OR REPLACE VIEW reporting.dim_queue AS
SELECT queue_id, queue_name, channel, sl_threshold_sec
FROM src.queues;

CREATE OR REPLACE VIEW reporting.dim_agent AS
SELECT agent_id, agent_name, team, site
FROM src.agents;

CREATE OR REPLACE VIEW reporting.dim_date AS
SELECT d::date                           AS date,
       to_char(d, 'Dy')                  AS day_name,
       extract(isodow FROM d)::int       AS day_of_week,
       date_trunc('week', d)::date       AS week_start,
       CASE WHEN extract(isodow FROM d) IN (6, 7)
            THEN 'Weekend' ELSE 'Weekday' END AS day_type
FROM generate_series((SELECT min(contact_date) FROM reporting.interactions),
                     (SELECT max(contact_date) FROM reporting.interactions),
                     interval '1 day') AS d;

CREATE OR REPLACE VIEW reporting.kpi_agent_daily AS
SELECT agent_id,
       contact_date,
       queue_id,
       count(*)        AS contacts_handled,
       sum(handle_sec) AS handle_sec_total
FROM reporting.interactions
WHERE channel IN ('voice', 'chat')
  AND outcome = 'answered'
  AND is_valid
GROUP BY agent_id, contact_date, queue_id;

-- ===== Lab 9C Part B: fax turnaround and quality scores =====
CREATE OR REPLACE VIEW reporting.kpi_fax_daily AS
SELECT i.queue_id,
       i.contact_date,
       count(*)                                                AS processed,
       count(*) FILTER (WHERE i.wait_sec <= q.sl_threshold_sec) AS within_target
FROM reporting.interactions i
JOIN src.queues q ON q.queue_id = i.queue_id
WHERE i.channel = 'fax'
GROUP BY i.queue_id, i.contact_date;

CREATE OR REPLACE VIEW reporting.kpi_qa_daily AS
SELECT s.agent_id,
       s.evaluated_date AS contact_date,
       i.queue_id,
       count(*)     AS scored,
       sum(s.score) AS score_total
FROM reporting.qa_clean s
JOIN reporting.interactions i ON i.channel = s.channel AND i.source_id = s.interaction_id
GROUP BY s.agent_id, s.evaluated_date, i.queue_id;
