# Demo 5C: a new day arrives

Time: 10 minutes, trainer-led

Goal: see the pipeline pick up only the new day, and see what an error looks like.

You need: Lab 5B finished, with the table full and the table in the `mean` setting.

## Part 1. New data arrives

The trainer adds 2 October to `src.calls`. This needs an administrator login, because your trainee login can only read that table. The trainer says when it is done.

> [!TIP]
> This is the morning delivery. Yesterday's boxes are already on the shelves. Today's boxes arrive, and the shop only unpacks the new ones.

## Part 2. Run the pipeline

When the trainer says so, run:

```powershell
python module-5-etl\agent_daily_etl.py
```

You should see:

```text
2026-10-23 08:30:12,411 INFO Extracting 2026-10-02 to 2026-10-02
2026-10-23 08:30:12,552 INFO Extracted 1763 calls
2026-10-23 08:30:12,560 INFO Transformed into 40 agent-day rows
2026-10-23 08:30:12,583 INFO Loaded. Watermark is now 2026-10-02
```

Only one day was processed: 1,763 calls and 40 rows, one per agent. The count in `reporting.agent_daily` is now 1,240.

> [!NOTE]
> What this does: the script read the bookmark (1 October), looked for newer days, found 2 October, processed only that, and moved the bookmark. The other 30 days were not touched.

## Part 3. What a failure looks like

The trainer stops the database for a moment, or gives the wrong password in `.env`. Run the script again.

You should see a line that starts with `ERROR ETL failed` followed by a long message. The last line of the message names the cause, for example `password authentication failed` or `connection refused`.

The tables are unchanged, because nothing is saved when the script fails. Fix the cause, run it again, and it carries on from the bookmark. That is why we use a transaction and a watermark.

## Done?

Next is [Module 6](../module-6-jsonb/README.md): storing data that does not fit neat columns.
