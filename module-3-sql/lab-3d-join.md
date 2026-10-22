# Lab 3D: join two tables

Time: 20 minutes

Goal: show queue names instead of queue numbers by combining two tables.

You need: Lab 3C finished.

The `calls` table stores a queue number. The `queues` table says what each number means. A join lines up the rows of the two tables using the number they share.

> [!TIP]
> A join is matching a guest list to a seating chart. Each guest has a table number, and the seating chart says what that table number means. The shared number is how you match them.

## Step 1. Join calls to queue names

```sql
SELECT c.call_id, q.queue_name, c.wait_sec
FROM practice.calls c
JOIN practice.queues q ON q.queue_id = c.queue_id
ORDER BY c.call_id
LIMIT 5;
```

You should see:

```text
 call_id | queue_name  | wait_sec
---------+-------------+----------
       1 | Billing     |        5
       2 | Billing     |       12
       3 | Claims      |       30
       4 | Billing     |        3
       5 | Eligibility |        8
```

> [!NOTE]
> What this does: `c` and `q` are short nicknames for the two tables, so you do not retype the long names. `JOIN ... ON q.queue_id = c.queue_id` says "line up each call with the queue that has the same queue number". Then `c.call_id` means the call_id column from calls, and `q.queue_name` means the name column from queues.

## Step 2. Count calls per queue name

```sql
SELECT q.queue_name, count(*) AS offered
FROM practice.calls c
JOIN practice.queues q ON q.queue_id = c.queue_id
GROUP BY q.queue_name
ORDER BY q.queue_name;
```

You should see:

```text
  queue_name   | offered
---------------+---------
 Billing       |       9
 Claims        |       6
 Eligibility   |       3
 Provider Line |       2
```

The numbers are the same as in Lab 3C, but now the report is readable by anyone.

## Step 3. A join that goes wrong

Remove the `ON` part to see what a bad join does:

```sql
SELECT count(*)
FROM practice.calls c
CROSS JOIN practice.queues q;
```

You should see `80`.

> [!NOTE]
> What this does: `CROSS JOIN` pairs every call with every queue: 20 calls times 4 queues is 80 rows. If a join result has far more rows than you expected, the `ON` condition is missing or wrong. Always check the row count after a join.

## Try it yourself

Add the average wait to Step 2, one decimal place, with the title `avg_wait_sec`.

<details>
<summary>Answer</summary>

```sql
SELECT q.queue_name, count(*) AS offered, round(avg(c.wait_sec), 1) AS avg_wait_sec
FROM practice.calls c
JOIN practice.queues q ON q.queue_id = c.queue_id
GROUP BY q.queue_name
ORDER BY q.queue_name;
```

You should see 17.7 for Billing, 22.2 for Claims, 19.3 for Eligibility and 13.0 for Provider Line.

</details>

## Check yourself

1. What does the `ON` line in a join do?
2. Why use nicknames like `c` and `q`?
3. If a join returns far too many rows, what is the likely cause?

<details>
<summary>Answers</summary>

1. It says which column in each table has to match.
2. They are shorter to type and make the query easier to read.
3. The matching condition is missing or wrong, so every row was paired with every other row.

</details>

## Done?

Next is [Lab 3E](lab-3e-call-centre-numbers.md): the call centre numbers.
