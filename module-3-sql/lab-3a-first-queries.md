# Lab 3A: connect and look inside the tables

Time: 30 minutes

Goal: open a connection to the database, run your first query and read the result.

You need: pgAdmin installed, and from your trainer the server name, the login (`trainee`) and the password.

## Step 1. Connect with pgAdmin

1. Open pgAdmin. If it asks for a master password, choose one and write it down.
2. In the left panel, right-click Servers and choose Register, then Server.
3. On the General tab, type the name `Training`.
4. On the Connection tab, fill in:
   * Host name/address: the server name from your trainer (use `localhost` if the database is on your own laptop)
   * Port: `5432`
   * Maintenance database: `contact_centre`
   * Username: `trainee`
   * Password: the one from your trainer
5. Tick Save password, then click Save.

You should see: `Training` appears under Servers with a small green or grey icon, and expands when you click it.

If you see "password authentication failed", retype the password carefully. If you see "could not connect to server", check the host name with your trainer.

## Step 2. Open a query window

1. In the left panel, expand Training, then Databases, then `contact_centre`.
2. Right-click `contact_centre` and choose Query Tool.

You should see an empty editor on the top half and an empty results area at the bottom.

## Step 3. Run your first query

Type this in the editor:

```sql
SELECT * FROM practice.queues;
```

Then click the Execute button (a triangle) or press F5.

You should see four rows in the results area:

```text
 queue_id |  queue_name   | sl_threshold_sec
----------+---------------+------------------
        1 | Billing       |               20
        2 | Claims        |               20
        3 | Eligibility   |               20
        4 | Provider Line |               20
```

pgAdmin draws this as a grid, so yours will look like a table instead of this text.

> [!NOTE]
> What this does: `SELECT` says what to show. The star means "every column". `FROM practice.queues` says which table. `practice` is the group of tables (a schema) and `queues` is the table inside it. It is like writing "room, then cabinet".

## Step 4. Look at the calls

Delete the old query and type:

```sql
SELECT * FROM practice.calls;
```

Run it. You should see 20 rows. The first rows are:

```text
 call_id | queue_id |     arrived_at      | wait_sec | talk_sec | hold_sec | wrap_sec |  outcome
---------+----------+---------------------+----------+----------+----------+----------+-----------
       1 |        1 | 2026-10-01 07:05:10 |        5 |      240 |        0 |       30 | answered
       2 |        1 | 2026-10-01 07:12:44 |       12 |      310 |       20 |       45 | answered
       3 |        2 | 2026-10-01 07:20:03 |       30 |      420 |       60 |       60 | answered
```

This is the same table as `calls_sample.csv` from this morning.

> [!TIP]
> Tip: if you have more than one query in the editor, select the text of the one you want with your mouse and press F5. pgAdmin runs only the selected text. Without a selection it runs everything and shows only the last result.

## Step 5. Pick the columns you want

```sql
SELECT call_id, queue_id, wait_sec, outcome
FROM practice.calls;
```

You should see 20 rows with only four columns.

> [!NOTE]
> What this does: naming the columns shows only those, in the order you wrote them. You can put the query on several lines. The database ignores line breaks and extra spaces. It is only there to make the query easier for you to read.

## Step 6. Show only a few rows

```sql
SELECT call_id, queue_id, wait_sec, outcome
FROM practice.calls
LIMIT 5;
```

You should see the first five rows.

> [!NOTE]
> What this does: `LIMIT 5` stops after five rows. On the full data, with 51,000 calls, this stops a query from flooding your screen. Without `ORDER BY` the database may give the rows in any order, so do not rely on which five you get.

## Step 7. Make a mistake on purpose

Run this, which is missing the letter `T` in `SELECT`:

```sql
SELEC call_id FROM practice.calls;
```

You should see an error message that includes `syntax error at or near "SELEC"`.

> [!NOTE]
> What this does: SQL errors name the word it did not understand. Spelling mistakes and missing commas cause most errors. Fix the word and run again.

## Check yourself

1. What does `*` mean in a `SELECT`?
2. What is `practice.calls`?
3. Why use `LIMIT` on a big table?

<details>
<summary>Answers</summary>

1. Every column.
2. The table `calls` inside the schema `practice`.
3. So you see only a few rows and the screen is not flooded.

</details>

## Done?

If you can run a query and see the 20 calls, go to [Lab 3B](lab-3b-filter-sort-count.md).
