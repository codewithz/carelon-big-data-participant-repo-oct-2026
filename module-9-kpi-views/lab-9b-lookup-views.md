# Lab 9B: lookup lists and the agent view

Time: 20 minutes

Goal: build the three small lookup lists Power BI needs (queues, agents, days) and a second counts view, one row per agent per queue per day.

You need: Lab 9A finished.

## Step 1. Queues and agents

These two are copies of tables you already have, made available next to your KPI views so Power BI finds everything in one place.

```sql
CREATE OR REPLACE VIEW reporting.dim_queue AS
SELECT queue_id, queue_name, channel, sl_threshold_sec
FROM src.queues;

CREATE OR REPLACE VIEW reporting.dim_agent AS
SELECT agent_id, agent_name, team, site
FROM src.agents;
```

Select both statements and press F5. You should see `CREATE VIEW`. Check one:

```sql
SELECT * FROM reporting.dim_queue;
```

You should see six rows, Billing to Back Office Fax. The fax target is 14,400 seconds, which is 4 hours.

> [!NOTE]
> Why `dim_`: it is short for dimension, Power BI's word for a lookup list, something you slice the numbers by. The KPI views are the facts. You will see both words in Power BI.

## Step 2. A list of days

A report needs a list of every day, including days with no contacts, so that a chart shows a gap instead of skipping it.

```sql
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
```

Check it:

```sql
SELECT * FROM reporting.dim_date ORDER BY date LIMIT 5;
```

You should see:

```text
    date    | day_name | day_of_week | week_start | day_type
------------+----------+-------------+------------+----------
 2026-09-02 | Wed      |           3 | 2026-08-31 | Weekday
 2026-09-03 | Thu      |           4 | 2026-08-31 | Weekday
 2026-09-04 | Fri      |           5 | 2026-08-31 | Weekday
 2026-09-05 | Sat      |           6 | 2026-08-31 | Weekend
 2026-09-06 | Sun      |           7 | 2026-08-31 | Weekend
```

`SELECT count(*) FROM dim_date;` gives 30.

> [!NOTE]
> What this does: `generate_series` counts from the first day in your data to the last, one day at a time. Because the first and last day come from `interactions`, the list grows by itself when a new day is loaded. You will see that happen in Lab 10E. `isodow` numbers the days Monday 1 to Sunday 7.

## Step 3. One row per agent per queue per day

```sql
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
```

Check it:

```sql
SELECT count(*) AS rows, sum(contacts_handled) AS contacts
FROM reporting.kpi_agent_daily;
```

You should see 5,980 rows and 61,021 contacts.

> [!NOTE]
> What this does: it keeps answered calls and chats that have an agent (`is_valid`), then makes one pile per agent, day and queue. This is where the flag from Lab 8B earns its place: the 150 answered calls with no agent are in the queue view but not in this one. Keeping `queue_id` in the view lets a queue filter in Power BI narrow the agent table too.

## Step 4. Check against Day 1

In Demo 3F the fastest Billing agent on 1 October was agent 3 with 267 seconds. Check:

```sql
SELECT agent_id, contacts_handled,
       round(1.0 * handle_sec_total / contacts_handled) AS aht_sec
FROM reporting.kpi_agent_daily
WHERE queue_id = 1 AND contact_date = '2026-10-01'
ORDER BY aht_sec
LIMIT 3;
```

You should see:

```text
 agent_id | contacts_handled | aht_sec
----------+------------------+---------
        3 |               11 |     267
       40 |               15 |     274
       37 |                9 |     279
```

## Check yourself

1. Why build `dim_date` instead of using the dates in the KPI views?
2. Why does `kpi_agent_daily` use `is_valid` but `kpi_queue_daily` does not?
3. What will `dim_date` contain after a new day is loaded?

<details>
<summary>Answers</summary>

1. A day with no contacts has no row in a KPI view, so it would be missing from charts and filters. The list of days has every day.
2. A call with no agent still counts for its queue, but cannot be given to any agent.
3. 31 days, because its last day comes from `interactions`.

</details>

## Done?

Next is [Lab 9C](lab-9c-check-the-numbers.md).
