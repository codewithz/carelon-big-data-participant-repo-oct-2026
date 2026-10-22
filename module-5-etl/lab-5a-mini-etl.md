# Lab 5A: a tiny ETL

Time: 30 minutes

Goal: build all three ETL steps in a small script, then find out what goes wrong when a script is run twice.

You need: Module 4 finished.

## Step 1. Write the three steps

Create `work/queue_summary.py` and type:

```python
import pandas as pd

# EXTRACT: read the raw calls
calls = pd.read_csv("data/practice/calls_sample.csv")
print("Extracted", len(calls), "calls")

# TRANSFORM: keep answered calls and work out handle time per queue
answered = calls[calls["outcome"] == "answered"].copy()
answered["handle_sec"] = answered["talk_sec"] + answered["hold_sec"] + answered["wrap_sec"]
summary = answered.groupby("queue_id").agg(
    calls_handled=("call_id", "count"),
    aht_sec=("handle_sec", "mean"),
).reset_index()
summary["aht_sec"] = summary["aht_sec"].round().astype(int)
print(summary)

# LOAD: write the result to a file
summary.to_csv("work/queue_summary.csv", index=False)
print("Saved work/queue_summary.csv")
```

Save and run: `python work\queue_summary.py`

You should see:

```text
Extracted 20 calls
   queue_id  calls_handled  aht_sec
0         1              7      376
1         2              5      382
2         3              3      347
3         4              1      430
Saved work/queue_summary.csv
```

These are the numbers you worked out in Lab 3E. Queue 1 is Billing: 7 answered calls and 376 seconds.

> [!NOTE]
> What this does: the three comment lines mark Extract, Transform and Load. `groupby("queue_id")` makes one group per queue. `.agg(...)` calculates a number for each group: the count of calls and the average handle time. `.reset_index()` turns the queue number back into an ordinary column. `.round().astype(int)` makes the average a whole number.

## Step 2. Add to a history file

Managers want to keep a record of each run. Make two changes to the script.

First, add this line at the very top, above `import pandas as pd`:

```python
import os
```

Then add these lines at the bottom:

```python
# LOAD, version 2: add the result to a history file
history_file = "work/queue_history.csv"
summary.to_csv(history_file, mode="a", header=not os.path.exists(history_file), index=False)
print("Added to", history_file)
```

Save and run once: `python work\queue_summary.py`

Open `work/queue_history.csv`. It has 5 lines: a header and four queues.

> [!NOTE]
> What this does: `mode="a"` means append, which adds to the end of the file instead of replacing it. `header=not os.path.exists(history_file)` writes the column names only if the file did not exist yet.

## Step 3. Run it again

Without changing anything, run the script a second time. Then open `work/queue_history.csv`.

You should see 9 lines. The four queues now appear twice:

```text
queue_id,calls_handled,aht_sec
1,7,376
2,5,382
3,3,347
4,1,430
1,7,376
2,5,382
3,3,347
4,1,430
```

This is the problem. The script was run twice, nothing new happened in the world, and the numbers in the file doubled. If a report adds up this file, Billing now has 14 answered calls instead of 7.

> [!WARNING]
> This mistake happens in real teams. Someone reruns a job after a failure and every total is silently doubled. Nobody sees an error.

## Step 4. Make it safe to run twice

Delete the history file so you can start again. In the terminal:

```powershell
del work\queue_history.csv
```

Now change the history line in the script from:

```python
summary.to_csv(history_file, mode="a", header=not os.path.exists(history_file), index=False)
```

to:

```python
summary.to_csv(history_file, index=False)
```

Run the script twice. Open the file each time.

You should see 5 lines both times, the header and four queues.

> [!NOTE]
> What this does: without `mode="a"`, `to_csv` replaces the whole file each time. The result depends only on the input, not on how many times you ran the script. That is what makes it safe to run again.

## Step 5. Think about the database

Replacing a whole file is easy. Replacing a whole database table every day gets slow once the table has years of history, so the real ETL in Lab 5B does something smarter. It uses an upsert, which means "update the row if it exists, add it if it does not", and a watermark that remembers which days are already done.

## Check yourself

1. What are the three letters in ETL?
2. Why did the history file double?
3. What makes a script safe to run twice?

<details>
<summary>Answers</summary>

1. Extract, Transform, Load.
2. The script added to the end of the file every time, so the same four rows were added again.
3. Its result depends on the input and not on how often it ran, for example by overwriting the output or by updating rows that already exist.

</details>

## Done?

Next is [Lab 5B](lab-5b-real-etl.md): the same idea with a database.
