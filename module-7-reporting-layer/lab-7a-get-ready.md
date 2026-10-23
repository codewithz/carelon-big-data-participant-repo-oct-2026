# Lab 7A: get your database ready

Time: 10 minutes

Goal: add the Day 2 finished copies to your database, put `src` back to 30 days, and check your VM is ready.

You need: your VM with the Day 1 database, pgAdmin, and the Day 2 course files (SETUP.md, "Before Day 2").

## Step 1. Run the Day 2 setup script

1. In pgAdmin, expand `Training`, then Databases. Right-click `contact_centre` and choose Query Tool.
2. Click the Open File button (a folder icon) and pick `data\db\day2_setup.sql` from the course folder.
3. Press F5.

You should see one row at the bottom:

```text
 interactions | days
--------------+------
        68305 |   30
```

> [!NOTE]
> What this does: first it removes the pretend 2 October from Demo 5C yesterday, if you added it, so everyone starts from the same 30 days. Then it creates a schema called `solution` and builds finished copies of every table and view you will build today. It does not touch `reporting`, so your Day 1 work is safe.

## Step 2. Look at the schemas

In the left panel, right-click `contact_centre` and choose Refresh. Expand Schemas.

You should see `practice`, `public`, `reporting`, `solution` and `src`. Expand `solution`, then Views: there are nine views, from `dim_agent` to `qa_clean`.

Now run:

```sql
SELECT table_schema, table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'reporting'
ORDER BY table_name;
```

You should see what you built on Day 1:

```text
 table_schema |  table_name   | table_type
--------------+---------------+------------
 reporting    | agent_daily   | BASE TABLE
 reporting    | calls_clean   | VIEW
 reporting    | etl_watermark | BASE TABLE
```

If a row is missing, that Day 1 lab was not finished. It does not matter for Day 2.

## Step 3. Check from Python

In the terminal, with `(.venv)` showing, run:

```powershell
python check_day2.py
```

You should see every line start with OK, ending with:

```text
OK       Connected as postgres to contact_centre
OK       src holds 30 days (2 September to 1 October)
OK       The finished copies in solution are there

All good. You are ready for Day 2.
```

The full list has a few more lines above these. If a line says MISSING, the hint under it says what to do.

## Check yourself

1. What does `day2_setup.sql` change, and what does it leave alone?
2. You will build `reporting.kpi_queue_daily` today. Where is the finished copy?
3. You are the administrator. What stops you deleting rows from `src`?

<details>
<summary>Answers</summary>

1. It removes the pretend 2 October from `src` and builds the `solution` schema. It does not touch `reporting`.
2. `solution.kpi_queue_daily`.
3. Nothing but care. Read each statement before you press F5. If it happens, `data/db/setup_contact_centre.sql` resets the whole database.

</details>

## Done?

Next is [Module 8](../module-8-transform/README.md).
