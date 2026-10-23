-- Day 2 setup. Run once on your own VM, in pgAdmin (Open File, then F5), at the start of Day 2.
-- Or with psql:  "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d contact_centre -f data\db\day2_setup.sql
--
-- It does two things:
--   1. Removes the pretend 2 October from Day 1 Demo 5C, if it is there, so everyone
--      starts Day 2 from the same 30 days.
--   2. Builds finished copies of every Day 2 table and view in a schema called solution.
--      You build your own in reporting. Use solution to check your numbers, or to carry on
--      if your own version is broken.
-- Re-running is safe. It never touches the reporting schema.

SET TIME ZONE 'Asia/Manila';
SET client_min_messages = warning;

-- ===== 1. Back to 30 days =====
DELETE FROM src.calls WHERE call_id >= 1000000;
DELETE FROM src.chats WHERE chat_id >= 1000000;
DELETE FROM src.faxes WHERE fax_id >= 1000000;

-- ===== 2. The finished Day 2 objects in solution =====
-- interactions and qa_clean are views here, not tables, so they follow src automatically
-- when a new day is added. Your own versions in reporting are tables built by Python.
CREATE SCHEMA IF NOT EXISTS solution;

DROP VIEW IF EXISTS solution.kpi_queue_daily, solution.kpi_agent_daily, solution.kpi_fax_daily,
                    solution.kpi_qa_daily, solution.dim_date, solution.dim_queue, solution.dim_agent,
                    solution.interactions, solution.qa_clean CASCADE;

-- The same rules as module-8-transform/build_interactions.py, written in SQL.
CREATE VIEW solution.interactions AS
SELECT 'voice'::text AS channel, c.call_id AS source_id, c.queue_id::bigint, c.agent_id::bigint,
       c.arrived_at, c.answered_at, c.ended_at,
       (c.arrived_at AT TIME ZONE 'Asia/Manila')::date AS contact_date,
       c.wait_sec::bigint, (c.talk_sec + c.hold_sec + c.wrap_sec)::bigint AS handle_sec,
       c.outcome, NOT (c.outcome = 'answered' AND c.agent_id IS NULL) AS is_valid
FROM (SELECT DISTINCT * FROM src.calls) c
UNION ALL
SELECT 'chat', h.chat_id, h.queue_id, h.agent_id,
       h.started_at_local AT TIME ZONE 'Asia/Manila',
       h.accepted_at_local AT TIME ZONE 'Asia/Manila',
       h.ended_at_local AT TIME ZONE 'Asia/Manila',
       h.started_at_local::date,
       round(extract(epoch FROM CASE WHEN h.outcome = 'answered' THEN h.accepted_at_local
                                     ELSE h.ended_at_local END - h.started_at_local))::bigint,
       CASE WHEN h.outcome = 'answered' THEN h.handle_sec ELSE 0 END,
       h.outcome, NOT (h.outcome = 'answered' AND h.agent_id IS NULL)
FROM src.chats h
UNION ALL
SELECT 'fax', f.fax_id, f.queue_id, f.agent_id,
       f.received_at, f.processed_at, f.processed_at,
       (f.received_at AT TIME ZONE 'Asia/Manila')::date,
       round(extract(epoch FROM f.processed_at - f.received_at))::bigint,
       0, f.status, true
FROM src.faxes f;

CREATE VIEW solution.qa_clean AS
SELECT qa_id, channel, interaction_id, agent_id::bigint,
       (evaluated_at AT TIME ZONE 'Asia/Manila')::date AS evaluated_date,
       rtrim(score_text, '%')::bigint AS score
FROM src.qa_scores;

-- The KPI views: the same SQL as module-9-kpi-views/solutions/kpi_views.sql, in solution.
-- ===== Lab 9A: one row per queue per day, counts only =====
CREATE OR REPLACE VIEW solution.kpi_queue_daily AS
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
FROM solution.interactions i
JOIN src.queues q ON q.queue_id = i.queue_id
WHERE i.channel IN ('voice', 'chat')
GROUP BY i.queue_id, i.contact_date;

-- ===== Lab 9B: the lookup lists and the agent view =====
CREATE OR REPLACE VIEW solution.dim_queue AS
SELECT queue_id, queue_name, channel, sl_threshold_sec
FROM src.queues;

CREATE OR REPLACE VIEW solution.dim_agent AS
SELECT agent_id, agent_name, team, site
FROM src.agents;

CREATE OR REPLACE VIEW solution.dim_date AS
SELECT d::date                           AS date,
       to_char(d, 'Dy')                  AS day_name,
       extract(isodow FROM d)::int       AS day_of_week,
       date_trunc('week', d)::date       AS week_start,
       CASE WHEN extract(isodow FROM d) IN (6, 7)
            THEN 'Weekend' ELSE 'Weekday' END AS day_type
FROM generate_series((SELECT min(contact_date) FROM solution.interactions),
                     (SELECT max(contact_date) FROM solution.interactions),
                     interval '1 day') AS d;

CREATE OR REPLACE VIEW solution.kpi_agent_daily AS
SELECT agent_id,
       contact_date,
       queue_id,
       count(*)        AS contacts_handled,
       sum(handle_sec) AS handle_sec_total
FROM solution.interactions
WHERE channel IN ('voice', 'chat')
  AND outcome = 'answered'
  AND is_valid
GROUP BY agent_id, contact_date, queue_id;

-- ===== Lab 9C Part B: fax turnaround and quality scores =====
CREATE OR REPLACE VIEW solution.kpi_fax_daily AS
SELECT i.queue_id,
       i.contact_date,
       count(*)                                                AS processed,
       count(*) FILTER (WHERE i.wait_sec <= q.sl_threshold_sec) AS within_target
FROM solution.interactions i
JOIN src.queues q ON q.queue_id = i.queue_id
WHERE i.channel = 'fax'
GROUP BY i.queue_id, i.contact_date;

CREATE OR REPLACE VIEW solution.kpi_qa_daily AS
SELECT s.agent_id,
       s.evaluated_date AS contact_date,
       i.queue_id,
       count(*)     AS scored,
       sum(s.score) AS score_total
FROM solution.qa_clean s
JOIN solution.interactions i ON i.channel = s.channel AND i.source_id = s.interaction_id
GROUP BY s.agent_id, s.evaluated_date, i.queue_id;

-- Check: expect 68305 interactions and 30 days.
SELECT (SELECT count(*) FROM solution.interactions) AS interactions,
       (SELECT count(*) FROM solution.dim_date)     AS days;
