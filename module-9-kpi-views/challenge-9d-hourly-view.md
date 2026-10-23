# Challenge 9D: one level finer, and proof it adds up

Time: 30 minutes. A challenge: fewer instructions, more thinking. Do it after Lab 9C if you have time, or at home.

Goal: build a KPI view by the hour, prove that its hours add up exactly to the daily view, and find the worst hours of the month.

You need: Lab 9C finished. If you did Challenge 3G on Day 1, you have done this for one queue and one day. Now it is every queue and every day, as a view.

## Why

The daily view says Billing's service level over the month was about 73 percent. Staffing is planned by the hour. The team leader needs the same counts, one level finer. And before anyone trusts a new view, it has to agree with the one they already use.

## Step 1. Plan it

Answer on paper, looking at `reporting.kpi_queue_daily` in `solutions/kpi_views.sql`:

1. Which lines stay exactly the same?
2. What is added to the `SELECT`?
3. What is added to the `GROUP BY`?

<details>
<summary>Compare</summary>

1. Every count, the `FROM`, the `JOIN` and the `WHERE`. The KPI rules do not change because the grain changes.
2. One column: the hour of `arrived_at`, in Manila time, as a whole number.
3. The same hour calculation.

</details>

## Step 2. Build it

Create `reporting.kpi_queue_hourly`, with the columns `queue_id`, `contact_date`, `hour`, then the same eight counts as the daily view, in the same order.

<details>
<summary>Hint: the hour</summary>

```sql
extract(hour FROM i.arrived_at AT TIME ZONE 'Asia/Manila')::int AS hour
```

In `GROUP BY` write the calculation again, without `AS hour`. PostgreSQL does not let `GROUP BY` use a name made in the same `SELECT` in every case, so writing it out is the safe habit.

</details>

## Step 3. Check its size

Count the rows and the first and last hour. You should see 2,099 rows, from hour 7 to hour 20.

That is fewer than 5 queues times 30 days times 14 hours (2,100). Eligibility had no calls at all from 7:00 to 8:00 on 5 September, so that hour has no row. A list of hours, like `dim_date` for days, would show that gap.

## Step 4. Reconcile

This is the important step. Add the hours back up to one row per queue per day, and compare with `reporting.kpi_queue_daily` using `EXCEPT ALL`, in both directions.

You should see 0 and 0.

<details>
<summary>Hint: the shape of the query</summary>

```sql
WITH from_hours AS (
    SELECT queue_id, contact_date,
           sum(reached) AS reached,
           -- ... the other seven counts, in the same order ...
    FROM reporting.kpi_queue_hourly
    GROUP BY queue_id, contact_date
)
SELECT (SELECT count(*) FROM (SELECT * FROM from_hours
                              EXCEPT ALL SELECT * FROM reporting.kpi_queue_daily) a) AS only_in_hours,
       (SELECT count(*) FROM (SELECT * FROM reporting.kpi_queue_daily
                              EXCEPT ALL SELECT * FROM from_hours) b) AS only_in_days;
```

`WITH` gives a query a name for the next query to use, like a view that lasts for one statement.

</details>

> [!NOTE]
> Why both directions: `only_in_hours` catches rows the hourly view invents, `only_in_days` catches rows it loses. One direction alone can hide a problem. Real teams run this kind of check every time they add a finer or a new view.

## Step 5. The worst hours of the month

For the four voice queues together, work out the service level for each hour across the whole month, and show the three worst. Remember Lab 9C: add the counts first, then divide once.

You should see:

```text
 hour | offered | service_level_pct
------+---------+-------------------
   11 |    5040 |              65.2
   10 |    5010 |              66.2
   16 |    4391 |              67.4
```

The month's voice service level is 73.0 percent. Late morning, the busiest time, sits eight points below it.

## Check yourself

1. Why do the KPI rules not change when you go from days to hours?
2. Your reconciliation shows `only_in_hours` 0 but `only_in_days` 150. What happened?
3. Could you build `kpi_queue_daily` from `kpi_queue_hourly` instead of from `interactions`? Would you?

<details>
<summary>Answers</summary>

1. The rules say what counts as offered, abandoned or in time. The grain only says how the rows are piled up.
2. All 150 daily rows are missing from your hours: `from_hours` came back empty. The usual cause is a `WHERE` inside it that matches nothing. If the column order were wrong, both numbers would be above 0.
3. Yes, by adding up the hours, exactly as in Step 4. Many teams do: one finest view, everything else added up from it, so the numbers cannot disagree.

</details>

The finished SQL is in `solutions/challenge-9d-hourly.sql`. Look only after you have tried.
