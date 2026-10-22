# Lab 3E: the call centre numbers

Time: 45 minutes

Goal: work out three call centre numbers by hand on 20 calls, then make SQL give the same answers, then run the same SQL on a full day of real data.

You need: Lab 3D finished.

Managers ask for three numbers every day. You will do each one on paper first. If you cannot do it on paper, the SQL will feel like magic. If you can, the SQL is just the same steps written down.

> [!TIP]
> A teacher marking a test does the first paper by hand, then sets up a spreadsheet and checks that it gives the same mark. You are doing the same thing: hand first, tool second, compare.

## The three numbers

| Number | Meaning | Rule |
|---|---|---|
| Abandonment rate | Share of callers who hung up before anyone answered | abandoned calls ÷ offered calls |
| AHT (average handle time) | How long an agent spends on one call, in seconds | talk + hold + wrap, averaged over answered calls |
| Service level | Share of callers answered quickly enough | answered within the target ÷ (answered + abandoned after the target) |

Two rules matter. The target wait for every queue is 20 seconds. A caller who hangs up within 5 seconds probably dialled the wrong number, so those calls are left out of every number. They are called short abandons.

> [!NOTE]
> These are common industry rules, and your company may define them differently. Your trainer will tell you if the real rules differ.

## Part 1. Do Billing by hand

Open the file `data/practice/calls_sample.csv` in VS Code, or use the table below. These are the 9 Billing calls (queue 1). Fill in the last columns yourself with pen and paper.

| call_id | wait_sec | talk_sec | hold_sec | wrap_sec | outcome |
|---|---|---|---|---|---|
| 1 | 5 | 240 | 0 | 30 | answered |
| 2 | 12 | 310 | 20 | 45 | answered |
| 4 | 3 | 0 | 0 | 0 | abandoned |
| 7 | 18 | 275 | 15 | 40 | answered |
| 10 | 25 | 500 | 90 | 70 | answered |
| 12 | 60 | 0 | 0 | 0 | abandoned |
| 14 | 9 | 290 | 0 | 30 | answered |
| 17 | 20 | 310 | 25 | 45 | answered |
| 20 | 7 | 265 | 0 | 35 | answered |

### Step 1. Abandonment rate

1. Cross out call 4. It was abandoned after 3 seconds, which is 5 or less, so it is a short abandon and does not count.
2. Count the calls left. That is the offered number.
3. Count how many of those are abandoned.
4. Divide abandoned by offered and multiply by 100.

Write your answer down before you open the answer.

<details>
<summary>Answer</summary>

Offered is 8 (nine calls minus the short abandon). Abandoned is 1 (call 12). 1 ÷ 8 = 0.125, so 12.5%.

</details>

### Step 2. AHT

1. Look only at answered calls. There are 7 of them: 1, 2, 7, 10, 14, 17 and 20.
2. For each one add talk, hold and wrap. Call 1 is 240 + 0 + 30 = 270.
3. Add up the seven handle times and divide by 7.

<details>
<summary>Answer</summary>

The seven handle times are 270, 375, 330, 660, 320, 380 and 300. They add up to 2635. 2635 ÷ 7 = 376.4, so about 376 seconds.

</details>

### Step 3. Service level

1. Go through the calls that are still counted (everything except call 4).
2. Mark each answered call whose wait is 20 seconds or less. These were answered in time.
3. Find abandoned calls with a wait over 20 seconds. They count against you.
4. Divide the in-time calls by (answered calls + late abandons) and multiply by 100.

<details>
<summary>Answer</summary>

Answered in time: calls 1, 2, 7, 14, 17 and 20, so 6. Call 10 waited 25 seconds, so it was too slow. The bottom of the fraction is 7 answered plus 1 late abandon (call 12, waited 60) which is 8. 6 ÷ 8 = 75.0%.

</details>

> [!WARNING]
> If your answers differ, do not go on yet. Find which call you counted differently. The most common slip is forgetting that call 17 waited exactly 20 seconds, which still counts as in time.

## Part 2. Let SQL do it for all four queues

Open pgAdmin and the Query Tool on the `contact_centre` database. Run each query by selecting it and pressing F5.

### Step 4. Abandonment rate

```sql
SELECT q.queue_name,
       count(*) AS offered,
       count(*) FILTER (WHERE c.outcome = 'abandoned') AS abandoned,
       round(100.0 * count(*) FILTER (WHERE c.outcome = 'abandoned') / count(*), 1) AS abandonment_pct
FROM practice.calls c
JOIN practice.queues q ON q.queue_id = c.queue_id
WHERE NOT (c.outcome = 'abandoned' AND c.wait_sec <= 5)
GROUP BY q.queue_name
ORDER BY q.queue_name;
```

You should see:

```text
  queue_name   | offered | abandoned | abandonment_pct
---------------+---------+-----------+-----------------
 Billing       |       8 |         1 |            12.5
 Claims        |       6 |         1 |            16.7
 Eligibility   |       3 |         0 |             0.0
 Provider Line |       1 |         0 |             0.0
```

Billing matches your hand answer of 12.5.

> [!NOTE]
> What this does: the `WHERE NOT (...)` line throws away the short abandons first, exactly as you crossed out call 4. `count(*)` then counts what is left. `count(*) FILTER (WHERE ...)` counts only the rows that pass the test in brackets, like counting only the red marbles in a jar. `100.0 *` makes the answer a percentage, and `round(..., 1)` keeps one decimal place.

### Step 5. AHT

```sql
SELECT q.queue_name,
       round(avg(c.talk_sec + c.hold_sec + c.wrap_sec)) AS aht_sec
FROM practice.calls c
JOIN practice.queues q ON q.queue_id = c.queue_id
WHERE c.outcome = 'answered'
GROUP BY q.queue_name
ORDER BY q.queue_name;
```

You should see 376 for Billing, 382 for Claims, 347 for Eligibility and 430 for Provider Line.

> [!NOTE]
> What this does: only answered calls are kept, because abandoned calls have no talk time. For each call SQL adds the three times, and `avg` averages them per queue, as you did on paper.

### Step 6. Service level

```sql
SELECT q.queue_name,
       count(*) FILTER (WHERE c.outcome = 'answered' AND c.wait_sec <= q.sl_threshold_sec) AS answered_in_time,
       count(*) FILTER (WHERE c.outcome = 'answered' OR c.wait_sec > q.sl_threshold_sec) AS counted,
       round(100.0 * count(*) FILTER (WHERE c.outcome = 'answered' AND c.wait_sec <= q.sl_threshold_sec)
             / count(*) FILTER (WHERE c.outcome = 'answered' OR c.wait_sec > q.sl_threshold_sec), 1) AS service_level_pct
FROM practice.calls c
JOIN practice.queues q ON q.queue_id = c.queue_id
WHERE NOT (c.outcome = 'abandoned' AND c.wait_sec <= 5)
GROUP BY q.queue_name
ORDER BY q.queue_name;
```

You should see:

```text
  queue_name   | answered_in_time | counted | service_level_pct
---------------+------------------+---------+-------------------
 Billing       |                6 |       8 |              75.0
 Claims        |                3 |       6 |              50.0
 Eligibility   |                2 |       3 |              66.7
 Provider Line |                0 |       1 |               0.0
```

Billing shows 6 and 8, the same fraction you wrote on paper.

> [!NOTE]
> What this does: `answered_in_time` is the top of the fraction and `counted` is the bottom. The `sl_threshold_sec` column comes from the queues table, which is why the join is needed. The percentage line repeats both pieces and divides them.

## Part 3. The same questions on a real day

The practice table had 20 rows. The real table has more than 51,000. The queries stay the same. Only the table name changes, and one extra step is needed first because the real data contains duplicate rows.

### Step 7. Look at the duplicates

```sql
SELECT count(*) AS rows_in_table, count(DISTINCT call_id) AS distinct_calls
FROM src.calls;
```

You should see:

```text
 rows_in_table | distinct_calls
---------------+----------------
         51363 |          51108
```

255 calls appear twice. Counting them would make every number too high.

> [!NOTE]
> What this does: `count(DISTINCT call_id)` counts each call number once, however many rows it appears on. The two numbers differ, so there are repeated rows.

### Step 8. Make a clean view

A view is a saved query that behaves like a table. You will save the clean-up once so every later query can use it.

```sql
CREATE OR REPLACE VIEW reporting.calls_clean AS
SELECT DISTINCT c.*, q.queue_name, q.sl_threshold_sec,
       (c.arrived_at AT TIME ZONE 'Asia/Manila')::date AS call_date
FROM src.calls c
JOIN src.queues q USING (queue_id);
```

You should see `CREATE VIEW`. Check it:

```sql
SELECT count(*) FROM reporting.calls_clean;
```

You should see 51108.

> [!NOTE]
> What this does: `SELECT DISTINCT` drops rows that are exact copies of another row. The join brings in the queue name and target. `AT TIME ZONE 'Asia/Manila'` turns the stored time into Manila time, then `::date` keeps only the date, so you can filter by day. A view stores the recipe, not a copy of the data.

### Step 9. Calls per queue for 1 October

```sql
SELECT queue_name,
       count(*) AS offered,
       count(*) FILTER (WHERE outcome = 'answered') AS answered,
       count(*) FILTER (WHERE outcome = 'abandoned') AS abandoned
FROM reporting.calls_clean
WHERE call_date = '2026-10-01'
GROUP BY queue_name
ORDER BY queue_name;
```

You should see:

```text
  queue_name   | offered | answered | abandoned
---------------+---------+----------+-----------
 Billing       |     573 |      524 |        49
 Claims        |     592 |      541 |        51
 Eligibility   |     413 |      378 |        35
 Provider Line |     354 |      324 |        30
```

### Step 10. All three numbers for 1 October

```sql
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
```

You should see:

```text
  queue_name   | offered | abandonment_pct | aht_sec | service_level_pct
---------------+---------+-----------------+---------+-------------------
 Billing       |     566 |             7.4 |     343 |              74.2
 Claims        |     583 |             7.2 |     349 |              75.7
 Eligibility   |     410 |             7.8 |     343 |              72.6
 Provider Line |     348 |             6.9 |     362 |              70.7
```

Offered is lower than in Step 9 because the short abandons are now left out.

> [!NOTE]
> What this does: it is Steps 4, 5 and 6 combined into one query, run on the clean view instead of the practice table. Every piece is something you already did by hand.

## Check yourself

1. Why are short abandons left out?
2. Why does AHT only use answered calls?
3. A call waited exactly 20 seconds and was answered. Does it count as in time?
4. Why did you create the view before counting calls on the real data?

<details>
<summary>Answers</summary>

1. Callers who hang up within a few seconds usually did not intend to wait, so they say nothing about how the queue performs.
2. Abandoned calls never reached an agent, so they have no talk, hold or wrap time.
3. Yes. The test is 20 seconds or less.
4. The real table has 255 duplicate rows, and counting them would inflate every number.

</details>

## Try it yourself

Change the date in Step 10 to `'2026-09-15'`. Do the numbers look similar to 1 October? Write one sentence on whether any queue looks different.

## Done?

You can now produce the three standard numbers. Your trainer will show a few advanced ideas in [Demo 3F](demo-3f-going-further.md), and then you move to [Module 4](../module-4-cleaning/README.md): cleaning data with Python.
