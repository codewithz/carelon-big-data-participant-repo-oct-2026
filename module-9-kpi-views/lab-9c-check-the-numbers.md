# Lab 9C: why counts, plus fax and QA

Time: 25 minutes

Goal: see with real numbers why a KPI must never be an average of averages, add the fax and quality score views, and check every view against the finished copies.

You need: Lab 9B finished.

## Part A. The averaging trap

A manager asks: "What was our AHT across all queues last month?" There are two ways to answer. One is wrong.

### Step 1. AHT for each queue

```sql
SELECT q.queue_name,
       sum(k.answered) AS answered,
       round(sum(k.handle_sec_total)::numeric / sum(k.answered)) AS aht_sec
FROM reporting.kpi_queue_daily k
JOIN reporting.dim_queue q USING (queue_id)
GROUP BY q.queue_name
ORDER BY q.queue_name;
```

You should see:

```text
  queue_name   | answered | aht_sec
---------------+----------+---------
 Billing       |    13964 |     351
 Claims        |    14022 |     353
 Eligibility   |    10154 |     352
 Provider Line |     8464 |     354
 Web Chat      |    14567 |     665
```

Before you run the next step: add up the five AHTs and divide by 5. Write the answer down.

### Step 2. Two ways to get one number

```sql
SELECT round(avg(queue_aht))                                   AS average_of_queue_ahts,
       round(sum(handle_total)::numeric / sum(answered_total)) AS true_aht
FROM (SELECT queue_id,
             sum(handle_sec_total)::numeric / sum(answered) AS queue_aht,
             sum(handle_sec_total)                          AS handle_total,
             sum(answered)                                  AS answered_total
      FROM reporting.kpi_queue_daily
      GROUP BY queue_id) AS per_queue;
```

You should see:

```text
 average_of_queue_ahts | true_aht
-----------------------+----------
                   415 |      427
```

The average of the five queue AHTs is 415 seconds. The real AHT, total handle time divided by total answered contacts, is 427 seconds. The first answer is 12 seconds too low.

> [!NOTE]
> Why: averaging the five queues gives each queue one equal vote. Provider Line (8,464 contacts) counts as much as Web Chat (14,567 contacts), and Web Chat has by far the longest handle time. The true AHT gives every contact one vote. Only the totals can do that, which is why the views keep totals.

### Step 3. The same trap with days

```sql
SELECT round(avg(100.0 * abandoned / offered), 2)      AS average_of_daily_rates,
       round(100.0 * sum(abandoned) / sum(offered), 2) AS true_rate
FROM reporting.kpi_queue_daily
WHERE queue_id = 1;
```

You should see:

```text
 average_of_daily_rates | true_rate
------------------------+-----------
                   7.09 |      7.20
```

Here the gap is small because the days in this course data are fairly even. In a real centre, a quiet Sunday with a terrible rate counts as much as a busy Monday in the average of days, and the gap gets bigger. The rule does not change with the size of the gap: add the counts, then divide.

In Power BI you will write every KPI as one total divided by another total, so this mistake cannot happen.

## Part B. Fax and quality scores

### Step 4. Fax turnaround

```sql
CREATE OR REPLACE VIEW reporting.kpi_fax_daily AS
SELECT i.queue_id,
       i.contact_date,
       count(*)                                                AS processed,
       count(*) FILTER (WHERE i.wait_sec <= q.sl_threshold_sec) AS within_target
FROM reporting.interactions i
JOIN src.queues q ON q.queue_id = i.queue_id
WHERE i.channel = 'fax'
GROUP BY i.queue_id, i.contact_date;
```

> [!NOTE]
> The fax target in the queue table is 14,400 seconds, which is 4 hours on the clock. The KPI definition talks about 4 business hours, which would not count nights and weekends. This course uses clock hours. If your centre uses business hours, this is the view to change, and the dashboard follows.

### Step 5. Quality scores

The QA scores belong to a call or chat. Joining them to `interactions` finds the queue, so a queue filter in Power BI can narrow them too.

```sql
CREATE OR REPLACE VIEW reporting.kpi_qa_daily AS
SELECT s.agent_id,
       s.evaluated_date AS contact_date,
       i.queue_id,
       count(*)     AS scored,
       sum(s.score) AS score_total
FROM reporting.qa_clean s
JOIN reporting.interactions i ON i.channel = s.channel AND i.source_id = s.interaction_id
GROUP BY s.agent_id, s.evaluated_date, i.queue_id;
```

> [!NOTE]
> What this does: `reporting.qa_clean` is the table Lab 8B built, with the score as a number. The join matches each score to its call or chat by channel and id. The date is the day the score was given, not the day of the call.

### Step 6. Check both

```sql
SELECT sum(processed) AS processed, sum(within_target) AS within_target,
       round(100.0 * sum(within_target) / sum(processed), 1) AS within_target_pct
FROM reporting.kpi_fax_daily;
```

You should see 1,754 processed, 1,367 within target, 77.9 percent.

```sql
SELECT sum(scored) AS scored,
       round(sum(score_total)::numeric / sum(scored), 1) AS average_score
FROM reporting.kpi_qa_daily;
```

You should see 3,076 scores and an average of 77.1, the same as Lab 8A step 4.

## Part C. Compare everything with the finished copies

### Step 7. One query, five checks

```sql
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
```

You should see five rows, each with `0`.

If a row is not 0, compare your view with the same view in `solutions/kpi_views.sql`, line by line. The usual cause is a `5` or `20` typed differently, or a missing `NOT`. Or open the whole solution file in pgAdmin, press F5 and carry on.

## Check yourself

1. Why is the average of the five queue AHTs lower than the true AHT?
2. Which number would you put in a report, and how would you explain the difference to a manager?
3. What would you change if the fax target became 4 business hours?

<details>
<summary>Answers</summary>

1. Web Chat has the longest handle time and many contacts. The plain average gives it only one fifth of the vote, the same as the smallest queue.
2. The true AHT, 427 seconds. "Each contact counts once. Averaging the queue numbers counts a small queue as much as a big one."
3. Only the `FILTER` in `kpi_fax_daily`. Everything built on top of it, including the dashboard, follows.

</details>

## Done?

Your views are ready. Next is [Module 10](../module-10-powerbi/README.md).
