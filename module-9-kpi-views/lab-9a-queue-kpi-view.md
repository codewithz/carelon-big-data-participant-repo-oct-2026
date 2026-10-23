# Lab 9A: the queue KPI view

Time: 30 minutes

Goal: count everything a queue's KPIs need for one queue on one day, check it against Day 1, then save the same counting as a view that covers every queue and every day.

You need: Lab 8B finished, and the pgAdmin Query Tool open on `contact_centre`.

## Step 1. Count Billing on 1 October

You know the answer to this from Lab 3E: 566 offered, 7.4 percent abandoned, AHT 343 seconds, service level 74.2 percent. This time you only count. No dividing.

```sql
SELECT count(*)                                                    AS reached,
       count(*) FILTER (WHERE outcome = 'abandoned' AND wait_sec <= 5) AS short_abandons,
       count(*) FILTER (WHERE outcome = 'abandoned' AND wait_sec > 5)  AS abandoned,
       count(*) FILTER (WHERE outcome = 'answered')                    AS answered,
       count(*) FILTER (WHERE outcome = 'answered' AND wait_sec <= 20) AS answered_in_sl,
       count(*) FILTER (WHERE outcome = 'abandoned' AND wait_sec > 20) AS abandoned_after_sl,
       sum(handle_sec) FILTER (WHERE outcome = 'answered')             AS handle_sec_total
FROM reporting.interactions
WHERE channel = 'voice' AND queue_id = 1 AND contact_date = '2026-10-01';
```

You should see:

```text
 reached | short_abandons | abandoned | answered | answered_in_sl | abandoned_after_sl | handle_sec_total
---------+----------------+-----------+----------+----------------+--------------------+------------------
     573 |              7 |        42 |      524 |            396 |                 10 |           179544
```

> [!NOTE]
> What this does: every column is a count of the rows that pass its own `FILTER`. `reached` is every call that reached the Billing queue that day. A short abandon is a caller who gave up within 5 seconds. `abandoned` here leaves the short abandons out, as the KPI rules say.

## Step 2. Divide by hand

With a calculator, from the numbers in Step 1 only:

1. Offered is reached minus short abandons: 573 − 7.
2. Abandonment rate is abandoned ÷ offered.
3. AHT is handle seconds ÷ answered.
4. Service level is answered in time ÷ (answered + abandoned after the target).

Write your four answers down, then open the answer.

<details>
<summary>Answer</summary>

1. 566
2. 42 ÷ 566 = 0.0742, which is 7.4 percent
3. 179,544 ÷ 524 = 342.6, which rounds to 343 seconds
4. 396 ÷ (524 + 10) = 396 ÷ 534 = 0.742, which is 74.2 percent

All four match Lab 3E.

</details>

The counts carry everything. Anyone with these seven numbers can work out all four KPIs, and can add them to another day's numbers first.

## Step 3. Save it as a view for every queue and day

Now take away the `WHERE` that picks one queue and one day, group instead, and save the query as a view. Two more changes: the target time comes from the queue table instead of a fixed 20, because chat has a 60 second target; and faxes are left out because they get their own view in Lab 9C.

```sql
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
```

You should see `CREATE VIEW`.

> [!NOTE]
> What this does: `GROUP BY i.queue_id, i.contact_date` makes one pile per queue per day, and every count runs inside its own pile. The join brings in `sl_threshold_sec`, the target for that queue. `coalesce(..., 0)` turns an empty total into 0 for a day where nothing was answered. `reporting.` in front of the name puts the view in the `reporting` schema, next to the table it reads.

## Step 4. Check its size

```sql
SELECT count(*) AS rows, count(DISTINCT queue_id) AS queues, count(DISTINCT contact_date) AS days
FROM reporting.kpi_queue_daily;
```

You should see:

```text
 rows | queues | days
------+--------+------
  150 |      5 |   30
```

Five queues (four voice, one chat) times 30 days is 150 rows. 68,305 contacts have become 150 rows of counts.

## Step 5. The KPIs for every queue on 1 October

Now divide, using only the view:

```sql
SELECT q.queue_name,
       k.offered,
       round(100.0 * k.abandoned / k.offered, 1)                                 AS abandonment_pct,
       round(1.0 * k.handle_sec_total / k.answered)                              AS aht_sec,
       round(100.0 * k.answered_in_sl / (k.answered + k.abandoned_after_sl), 1)  AS service_level_pct
FROM reporting.kpi_queue_daily k
JOIN src.queues q ON q.queue_id = k.queue_id
WHERE k.contact_date = '2026-10-01'
ORDER BY k.queue_id;
```

You should see:

```text
  queue_name   | offered | abandonment_pct | aht_sec | service_level_pct
---------------+---------+-----------------+---------+-------------------
 Billing       |     566 |             7.4 |     343 |              74.2
 Claims        |     583 |             7.2 |     349 |              75.7
 Eligibility   |     410 |             7.8 |     343 |              72.6
 Provider Line |     348 |             6.9 |     362 |              70.7
 Web Chat      |     556 |             5.8 |     659 |              90.7
```

The four voice queues match Lab 3E exactly. Web Chat is new: its target is 60 seconds and its handle time is the length of the chat.

> [!NOTE]
> Why `100.0` and `1.0`: if you divide one whole number by another, PostgreSQL gives a whole number back, so 42 ÷ 566 would be 0. Multiplying by `100.0` or `1.0` first makes it a decimal division.

## Check yourself

1. Why does the view store `abandoned` and `offered` instead of the abandonment rate?
2. Why does the view join to `src.queues`?
3. A day has 0 answered chats. What is `handle_sec_total`, and why?
4. Where is the finished copy of your view, and what is it for?

<details>
<summary>Answers</summary>

1. Counts can be added up for any set of days and queues, then divided. Percentages cannot be added up.
2. To get each queue's own target time: 20 seconds for voice, 60 for chat.
3. 0, because of `coalesce`. Without it the total would be empty (NULL).
4. `solution.kpi_queue_daily`. Compare your numbers with it, or use it if your own view is broken.

</details>

## Done?

Next is [Lab 9B](lab-9b-lookup-views.md).
