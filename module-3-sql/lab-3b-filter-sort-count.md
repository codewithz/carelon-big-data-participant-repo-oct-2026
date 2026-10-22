# Lab 3B: filter, sort and count

Time: 25 minutes

Goal: ask for only the rows you care about, put them in order and count them.

You need: Lab 3A finished and a query window open on `contact_centre`.

## Step 1. Filter with WHERE

> [!TIP]
> `WHERE` is the clerk's filter. "Only bring me the folders where the outcome says abandoned."

```sql
SELECT call_id, queue_id, wait_sec
FROM practice.calls
WHERE outcome = 'abandoned';
```

You should see four rows:

```text
 call_id | queue_id | wait_sec
---------+----------+----------
       4 |        1 |        3
       6 |        2 |       45
      12 |        1 |       60
      18 |        4 |        4
```

> [!NOTE]
> What this does: `WHERE outcome = 'abandoned'` keeps only the rows where the outcome column holds that word. Text goes in single quotes. The row order may differ on your screen.

## Step 2. Sort with ORDER BY

```sql
SELECT call_id, queue_id, wait_sec
FROM practice.calls
WHERE outcome = 'abandoned'
ORDER BY wait_sec DESC;
```

You should see the same four calls, longest wait first:

```text
 call_id | queue_id | wait_sec
---------+----------+----------
      12 |        1 |       60
       6 |        2 |       45
      18 |        4 |        4
       4 |        1 |        3
```

> [!NOTE]
> What this does: `ORDER BY wait_sec DESC` sorts by the wait column, biggest first (DESC means descending). Leave out `DESC` and you get smallest first.

## Step 3. Compare numbers

```sql
SELECT call_id, wait_sec
FROM practice.calls
WHERE wait_sec > 30
ORDER BY call_id;
```

You should see three rows: call 6 (45), call 12 (60) and call 15 (35).

Call 3 waited exactly 30 seconds and is not in the list. `>` means strictly more than. Use `>=` to include 30.

## Step 4. Combine conditions with AND and OR

```sql
SELECT call_id, wait_sec, talk_sec
FROM practice.calls
WHERE queue_id = 1 AND outcome = 'answered'
ORDER BY call_id;
```

You should see seven rows, calls 1, 2, 7, 10, 14, 17 and 20:

```text
 call_id | wait_sec | talk_sec
---------+----------+----------
       1 |        5 |      240
       2 |       12 |      310
       7 |       18 |      275
      10 |       25 |      500
      14 |        9 |      290
      17 |       20 |      310
      20 |        7 |      265
```

> [!NOTE]
> What this does: `AND` means both conditions must be true. `OR` means either one is enough. Queue 1 is Billing.

## Step 5. Count rows

```sql
SELECT count(*) FROM practice.calls;
```

You should see `20`.

```sql
SELECT count(*) FROM practice.calls WHERE outcome = 'abandoned';
```

You should see `4`.

> [!NOTE]
> What this does: `count(*)` counts how many rows come back. Combined with `WHERE` it counts only the matching rows. It gives one number instead of a list.

## Step 6. Biggest, smallest, average

```sql
SELECT max(wait_sec) AS longest_wait,
       min(wait_sec) AS shortest_wait,
       round(avg(wait_sec), 1) AS average_wait
FROM practice.calls;
```

You should see:

```text
 longest_wait | shortest_wait | average_wait
--------------+---------------+--------------
           60 |             3 |         18.8
```

The average, 18.8, is the same number you got from Python this morning. The same data gives the same answer in either tool.

> [!NOTE]
> What this does: `max`, `min` and `avg` look at the whole column and give one number. `AS longest_wait` gives the result a friendlier name. `round(..., 1)` keeps one decimal place.

## Try it yourself

Write a query that counts the answered calls whose wait was 20 seconds or less.

<details>
<summary>Answer</summary>

```sql
SELECT count(*)
FROM practice.calls
WHERE outcome = 'answered' AND wait_sec <= 20;
```

You should see 11. Check it by eye: there are 16 answered calls, and five of them waited more than 20 seconds (calls 3, 8, 10, 15 and 19). 16 minus 5 is 11.

</details>

## Check yourself

1. What is the difference between `>` and `>=`?
2. What does `DESC` do?
3. What does `count(*)` give you?

<details>
<summary>Answers</summary>

1. `>` means strictly more than. `>=` means more than or equal to.
2. It sorts biggest first.
3. The number of rows that match.

</details>

## Done?

Next is [Lab 3C](lab-3c-group-by.md).
