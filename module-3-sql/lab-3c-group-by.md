# Lab 3C: group rows into piles

Time: 20 minutes

Goal: count and average calls per queue instead of one big total.

You need: Lab 3B finished.

> [!TIP]
> `GROUP BY` is sorting a heap of receipts into one pile per cashier, then totalling each pile. You get one answer per pile instead of one answer for everything.

## Step 1. Calls per queue

```sql
SELECT queue_id, count(*) AS calls
FROM practice.calls
GROUP BY queue_id
ORDER BY queue_id;
```

You should see:

```text
 queue_id | calls
----------+-------
        1 |     9
        2 |     6
        3 |     3
        4 |     2
```

These match the counts from Lab 2D (9, 6, 3, 2). The numbers add up to the 20 calls.

> [!NOTE]
> What this does: `GROUP BY queue_id` makes one pile for each different queue number. `count(*)` then counts the rows in each pile. Anything in the `SELECT` that is not inside `count`, `avg` or similar must also appear in `GROUP BY`.

## Step 2. Answered and abandoned per queue

```sql
SELECT queue_id,
       count(*) AS offered,
       count(*) FILTER (WHERE outcome = 'answered')  AS answered,
       count(*) FILTER (WHERE outcome = 'abandoned') AS abandoned
FROM practice.calls
GROUP BY queue_id
ORDER BY queue_id;
```

You should see:

```text
 queue_id | offered | answered | abandoned
----------+---------+----------+-----------
        1 |       9 |        7 |         2
        2 |       6 |        5 |         1
        3 |       3 |        3 |         0
        4 |       2 |        1 |         1
```

Check it with the table: queue 1 has 9 calls, 2 of them abandoned (calls 4 and 12). Offered is answered plus abandoned.

> [!NOTE]
> What this does: `FILTER (WHERE ...)` counts only the rows that match inside each pile. One query gives you the total and the two outcomes side by side.

## Step 3. Average wait per queue

```sql
SELECT queue_id, round(avg(wait_sec), 1) AS avg_wait_sec
FROM practice.calls
GROUP BY queue_id
ORDER BY queue_id;
```

You should see:

```text
 queue_id | avg_wait_sec
----------+--------------
        1 |         17.7
        2 |         22.2
        3 |         19.3
        4 |         13.0
```

Check queue 4 by hand. It has two calls, with waits of 22 and 4. The average of 22 and 4 is 13.

## Step 4. Group by two things

```sql
SELECT queue_id, outcome, count(*) AS calls
FROM practice.calls
GROUP BY queue_id, outcome
ORDER BY queue_id, outcome;
```

You should see eight rows. The first two are queue 1 with `abandoned` 2 and `answered` 7.

> [!NOTE]
> What this does: listing two columns makes one pile for every combination, so queue 1 answered is a different pile from queue 1 abandoned.

## Try it yourself

Which queue has the longest average wait, and how long is it? Look at Step 3.

<details>
<summary>Answer</summary>

Queue 2 (Claims) at 22.2 seconds.

</details>

## Check yourself

1. What does `GROUP BY queue_id` do?
2. What does `FILTER (WHERE ...)` do inside `count(*)`?
3. Why do the counts per queue add up to 20?

<details>
<summary>Answers</summary>

1. It makes one pile of rows for each different queue number, and the calculation runs on each pile.
2. It counts only the rows in the pile that match the condition.
3. Every call belongs to exactly one queue.

</details>

## Done?

Next is [Lab 3D](lab-3d-join.md).
