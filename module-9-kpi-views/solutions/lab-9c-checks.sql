-- Lab 9C checks. Run in pgAdmin after kpi_views.sql.

-- Part A, Step 1: AHT for each queue over the whole month
SELECT q.queue_name,
       sum(k.answered)                                    AS answered,
       round(sum(k.handle_sec_total)::numeric / sum(k.answered)) AS aht_sec
FROM reporting.kpi_queue_daily k
JOIN reporting.dim_queue q USING (queue_id)
GROUP BY q.queue_name
ORDER BY q.queue_name;

-- Part A, Step 2: two ways to get one AHT for all queues
SELECT round(avg(queue_aht))                                     AS average_of_queue_ahts,
       round(sum(handle_total)::numeric / sum(answered_total))   AS true_aht
FROM (SELECT queue_id,
             sum(handle_sec_total)::numeric / sum(answered) AS queue_aht,
             sum(handle_sec_total)                          AS handle_total,
             sum(answered)                                  AS answered_total
      FROM reporting.kpi_queue_daily
      GROUP BY queue_id) AS per_queue;

-- Part A, Step 3: the same trap with daily abandonment rates, Billing
SELECT round(avg(100.0 * abandoned / offered), 2)          AS average_of_daily_rates,
       round(100.0 * sum(abandoned) / sum(offered), 2)     AS true_rate
FROM reporting.kpi_queue_daily
WHERE queue_id = 1;

-- Part B, Step 6: fax turnaround
SELECT sum(processed) AS processed, sum(within_target) AS within_target,
       round(100.0 * sum(within_target) / sum(processed), 1) AS within_target_pct
FROM reporting.kpi_fax_daily;

-- Part B, Step 7: quality scores
SELECT sum(scored) AS scored, round(sum(score_total)::numeric / sum(scored), 1) AS average_score
FROM reporting.kpi_qa_daily;

-- Part C, Step 7: compare every view with the finished copies in solution
SELECT 'kpi_queue_daily' AS view_name, count(*) AS only_in_mine
FROM (SELECT * FROM reporting.kpi_queue_daily EXCEPT ALL SELECT * FROM solution.kpi_queue_daily) d
UNION ALL
SELECT 'kpi_agent_daily', count(*)
FROM (SELECT * FROM reporting.kpi_agent_daily EXCEPT ALL SELECT * FROM solution.kpi_agent_daily) d
UNION ALL
SELECT 'kpi_fax_daily', count(*)
FROM (SELECT * FROM reporting.kpi_fax_daily EXCEPT ALL SELECT * FROM solution.kpi_fax_daily) d
UNION ALL
SELECT 'kpi_qa_daily', count(*)
FROM (SELECT * FROM reporting.kpi_qa_daily EXCEPT ALL SELECT * FROM solution.kpi_qa_daily) d
UNION ALL
SELECT 'dim_date', count(*)
FROM (SELECT * FROM reporting.dim_date EXCEPT ALL SELECT * FROM solution.dim_date) d;
