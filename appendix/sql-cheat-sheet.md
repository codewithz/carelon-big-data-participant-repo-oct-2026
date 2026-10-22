# SQL cheat sheet

Every pattern from Module 3 on one page. Replace the names with your own.

## The shape of a query

```sql
SELECT column1, column2   -- which columns
FROM schema.table         -- which table
WHERE condition           -- which rows
ORDER BY column1 DESC     -- in what order
LIMIT 10;                 -- how many rows
```

## Filtering

| You want | Write |
|---|---|
| Equal to text | `WHERE outcome = 'abandoned'` |
| Greater than | `WHERE wait_sec > 20` |
| Both true | `WHERE outcome = 'answered' AND wait_sec <= 20` |
| Either true | `WHERE queue_id = 1 OR queue_id = 2` |
| Not | `WHERE NOT (outcome = 'abandoned' AND wait_sec <= 5)` |
| Is empty | `WHERE agent_id IS NULL` |
| Is not empty | `WHERE agent_id IS NOT NULL` |

## Counting and averaging

| You want | Write |
|---|---|
| Count rows | `count(*)` |
| Count different values | `count(DISTINCT call_id)` |
| Count rows that pass a test | `count(*) FILTER (WHERE outcome = 'answered')` |
| Average | `avg(wait_sec)` |
| Add up | `sum(talk_sec)` |
| Smallest, largest | `min(wait_sec)`, `max(wait_sec)` |
| Round to 1 decimal | `round(x, 1)` |
| Percentage | `round(100.0 * part / total, 1)` |
| Rename a result | `count(*) AS offered` |

## Groups

```sql
SELECT queue_id, count(*) AS calls
FROM practice.calls
GROUP BY queue_id
ORDER BY queue_id;
```

Every column in `SELECT` that is not inside `count`, `avg` or `sum` must also appear in `GROUP BY`.

## Joins

```sql
SELECT c.call_id, q.queue_name
FROM practice.calls c
JOIN practice.queues q ON q.queue_id = c.queue_id;
```

## Dates and time zones

| You want | Write |
|---|---|
| Time in Manila | `arrived_at AT TIME ZONE 'Asia/Manila'` |
| Only the date | `(arrived_at AT TIME ZONE 'Asia/Manila')::date` |
| Only the hour | `extract(hour FROM arrived_at AT TIME ZONE 'Asia/Manila')` |

## Views

```sql
CREATE OR REPLACE VIEW reporting.calls_clean AS
SELECT DISTINCT * FROM src.calls;
```

## Common mistakes

| Mistake | What happens |
|---|---|
| Forgetting the `;` | The query waits or runs the next line together with it |
| Using double quotes for text | Error. Text uses single quotes: `'abandoned'` |
| Forgetting `GROUP BY` | Error: column must appear in the GROUP BY clause |
| Running the whole editor | Select the query first, then press F5 |
| Counting before removing duplicates | Every number is too high |
