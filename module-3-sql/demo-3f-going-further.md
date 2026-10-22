# Demo 3F: going further

Time: 15 minutes, trainer-led

Goal: see three ideas that real reports use. You watch and follow along. Nothing here is homework, and you are not expected to write these yourself yet.

You need: the `reporting.calls_clean` view from Lab 3E.

## Idea 1. Ranking agents

Managers like a leaderboard. SQL can number rows inside groups using a window function.

> [!TIP]
> A window function is a race with several heats. Everyone in a heat gets a finishing position, but the heats stay separate.

```sql
SELECT queue_name, agent_id, round(avg(talk_sec + hold_sec + wrap_sec)) AS aht_sec,
       RANK() OVER (PARTITION BY queue_name ORDER BY avg(talk_sec + hold_sec + wrap_sec)) AS aht_rank
FROM reporting.calls_clean
WHERE call_date = '2026-10-01' AND outcome = 'answered' AND agent_id IS NOT NULL
GROUP BY queue_name, agent_id
ORDER BY queue_name, aht_rank
LIMIT 6;
```

The top of the output:

```text
 queue_name | agent_id | aht_sec | aht_rank
------------+----------+---------+----------
 Billing    |        3 |     267 |        1
 Billing    |       40 |     274 |        2
 Billing    |       37 |     279 |        3
 Billing    |       38 |     296 |        4
 Billing    |       19 |     302 |        5
 Billing    |       30 |     302 |        6
```

> [!NOTE]
> What this does: `PARTITION BY queue_name` makes one heat per queue. `ORDER BY` inside the brackets says the shortest AHT finishes first. Agents 19 and 30 both show 302 seconds, but the true averages differ by a fraction of a second before rounding, so they get different ranks. If two averages were exactly equal, `RANK` would give them the same number.

## Idea 2. A running total

```sql
WITH hourly AS (
  SELECT extract(hour FROM arrived_at AT TIME ZONE 'Asia/Manila')::int AS call_hour, count(*) AS offered
  FROM reporting.calls_clean
  WHERE call_date = '2026-10-01' AND queue_name = 'Billing'
  GROUP BY 1)
SELECT call_hour, offered, sum(offered) OVER (ORDER BY call_hour) AS running_total
FROM hourly
ORDER BY call_hour;
```

The result has 14 rows. The first three and the last:

```text
 call_hour | offered | running_total
-----------+---------+---------------
         7 |      14 |            14
         8 |      37 |            51
         9 |      47 |            98
       ...
        20 |      20 |           573
```

The last running total is 573, the number of Billing calls for the day from Lab 3E.

> [!NOTE]
> What this does: the `WITH hourly AS (...)` part makes a small temporary table first, like writing a sub-total on scrap paper before the final sum. The window `sum(...) OVER (ORDER BY call_hour)` adds each hour to everything before it, like a bank balance after each deposit.

## Idea 3. First contact resolution

First contact resolution (FCR) asks: of the customers who got an answer, how many did not call again within 7 days? It is hard because each call has to look at other calls.

```sql
WITH day_calls AS (
  SELECT call_id, customer_id, arrived_at FROM reporting.calls_clean
  WHERE outcome = 'answered' AND arrived_at >= '2026-09-15 00:00+08' AND arrived_at < '2026-09-16 00:00+08')
SELECT count(*) AS answered_calls,
  count(*) FILTER (WHERE NOT EXISTS (
    SELECT 1 FROM reporting.calls_clean n
    WHERE n.customer_id = d.customer_id AND n.call_id <> d.call_id
      AND n.outcome = 'answered' AND n.arrived_at > d.arrived_at
      AND n.arrived_at <= d.arrived_at + interval '7 days')) AS resolved
FROM day_calls d;
```

You should see 1766 answered calls and 1267 resolved, which is 71.7%.

> [!NOTE]
> What this does: for every answered call on 15 September, the inner `SELECT` looks for the same customer calling again in the next 7 days. `NOT EXISTS` is true when it finds nobody. The customer numbers in this practice data are random, so 71.7% shows the method and is not a benchmark.

## Why show this now

You will not write these on Day 1. The point is to know that SQL can do rankings, running totals and look-ahead checks, so when a manager asks for one you know where to look.

## Done?

Next is [Module 4](../module-4-cleaning/README.md): cleaning messy data with Python.
