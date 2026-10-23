# Challenge 5D: build your own pipeline

Time: 40 minutes. A challenge: fewer instructions, more thinking. Do it after Demo 5C, or at home.

Goal: build a second pipeline on your own, for chats instead of calls. Same three steps, same two safety ideas (the watermark and the upsert). When you can do this without copying a finished answer, you understand ETL.

You need: Lab 5B and Demo 5C finished, and `src` back to 30 days (run `data\db\undo_new_day.sql` if you added 2 October, then run the call pipeline once more).

## The job

A team leader asks: "Can I have the same agent summary for web chat?" One row per agent per day, with the number of chats, the average chat length and the longest chat.

| | Calls pipeline (Lab 5B) | Your chat pipeline |
|---|---|---|
| Source | `src.calls` | `src.chats` |
| Rows to keep | Answered, with an agent | Answered, with an agent |
| Day of the contact | `arrived_at` in Manila time | `started_at_local` (already Manila clock time) |
| Length of one contact | `talk_sec + hold_sec + wrap_sec` | `handle_sec` (already worked out) |
| Target table | `reporting.agent_daily` | `reporting.chat_agent_daily` |
| Watermark job name | `agent_daily` | `chat_agent_daily` |
| Script | `module-5-etl/agent_daily_etl.py` | `work/chat_daily_etl.py` (yours) |

## Step 1. Plan on paper first

Before you touch the keyboard, copy this table onto paper and fill in the right-hand column in your own words. Five minutes.

| ETL step | What exactly happens in your pipeline? |
|---|---|
| Extract | Which table, which columns, which rows, which days? |
| Transform | What is grouped, and what is worked out for each group? |
| Load | Which table, and what happens if the row is already there? |
| Watermark | What is stored, and what does a second run find? |

<details>
<summary>Compare with this plan</summary>

| ETL step | What happens |
|---|---|
| Extract | From `src.chats`: `chat_id`, `agent_id`, `handle_sec` and the date of `started_at_local`, for answered chats with an agent, for the days after the watermark |
| Transform | Group by agent and day. Count the chats, average `handle_sec`, take the largest `handle_sec` |
| Load | Upsert into `reporting.chat_agent_daily`: insert new agent-days, update ones already there |
| Watermark | Store the last day loaded under the job name `chat_agent_daily`. A second run finds no newer day and stops |

</details>

## Step 2. Make the target table

Write a `CREATE TABLE IF NOT EXISTS reporting.chat_agent_daily (...)` in pgAdmin. Copy the shape of `reporting.agent_daily` from Lab 5B step 1, and change the column names to fit chats: `chats_handled` and `longest_chat_sec`.

Run it. You should see `CREATE TABLE`.

<details>
<summary>Hint</summary>

The primary key is what makes the upsert work. It must be the pair (agent, day), exactly as in `agent_daily`.

</details>

## Step 3. Copy the script and change it

1. Copy `module-5-etl/agent_daily_etl.py` to `work/chat_daily_etl.py`.
2. Change it. There are six places. Find each one yourself before you open the hint.

<details>
<summary>Hint: the six places</summary>

| Look for | Change |
|---|---|
| `JOB_NAME = "agent_daily"` | The job name |
| `def extract` | The table, the columns, the rows kept, and how the date is worked out |
| `def transform` | There is no talk, hold and wrap to add up. Use `handle_sec`. Rename the result columns |
| `UPSERT` | The table name and the column names, in all three places they appear |
| `SELECT max(...)` inside `def run` | The latest day must come from `src.chats` |
| `def reset` | The table to empty |

Also change the log file name in `setup_logging` to `chat_etl.log`, and the word `calls` in the log messages to `chats`, so the two pipelines are easy to tell apart.

</details>

## Step 4. Run it

```powershell
python work\chat_daily_etl.py
```

You should see:

```text
2026-10-23 16:47:12,961 INFO Extracting 2026-09-02 to 2026-10-01
2026-10-23 16:47:13,075 INFO Extracted 14567 chats
2026-10-23 16:47:13,138 INFO Transformed into 1200 agent-day rows
2026-10-23 16:47:13,223 INFO Loaded. Watermark is now 2026-10-01
```

If you see an error, read its last line first. The usual causes are a column name that still says `calls_handled`, or a `SELECT` that still reads `src.calls`.

## Step 5. Prove it is right

Write the checks yourself, in pgAdmin. You should get:

| Check | Expected |
|---|---|
| Rows in `reporting.chat_agent_daily` | 1,200 (40 agents times 30 days) |
| Sum of `chats_handled` | 14,567, the number of answered chats with an agent in `src.chats` |
| Agent 1 on 2 September | 19 chats, AHT 676, longest 1,399 |
| Rows in `reporting.etl_watermark` | Two: `agent_daily` and `chat_agent_daily`, both 1 October |

<details>
<summary>Hint: the second check from the other side</summary>

```sql
SELECT count(*) FROM src.chats WHERE outcome = 'answered' AND agent_id IS NOT NULL;
```

If this number and the sum in your table are the same, no chat was lost or counted twice.

</details>

## Step 6. Prove it is safe

1. Run the script a second time. You should see `Nothing new after 2026-10-01. Done.` and the checks in Step 5 do not change.
2. Run `data\db\simulate_new_day.sql` in pgAdmin. Run your script again. You should see `Extracting 2026-10-02 to 2026-10-02`, `Extracted 524 chats` and `Transformed into 40 agent-day rows`.
3. Run `data\db\undo_new_day.sql`, then your script with `--reset`, then without it. You are back to 1,200 rows.

## Check yourself

1. Which of the six changes would silently give wrong numbers instead of an error if you forgot it?
2. You forgot to change `JOB_NAME`. What goes wrong?
3. Why does chat not need `AT TIME ZONE 'Asia/Manila'` here?

<details>
<summary>Answers</summary>

1. The `SELECT max(...)` in `run`. If it still reads `src.calls`, the latest day comes from calls. That happens to be the same day here, so it runs, but the day calls and chats arrive at different times it would load the wrong days. Silent bugs are the dangerous ones.
2. The chat pipeline reads and moves the call pipeline's bookmark. Whichever runs second finds "nothing new" and loads nothing.
3. Chat times are already stored as Manila clock times, with no time zone. On Day 2 you will see why that is still a problem.

</details>

The finished script is in `module-5-etl/solutions/chat_daily_etl.py`, and the table in `solutions/chat_etl_setup.sql`. Look only after you have tried.
