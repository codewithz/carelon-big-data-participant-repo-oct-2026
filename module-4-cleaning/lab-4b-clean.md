# Lab 4B: write the cleaning script

Time: 30 minutes

Goal: write a script that removes repeats, fixes the wait column, sets aside bad rows, and saves two files.

You need: Lab 4A finished.

You will build `work/clean_calls.py` one step at a time. Run it after every step, so if something breaks you know which step caused it.

## Step 1. Read the file

Create `work/clean_calls.py` and type:

```python
import pandas as pd

pd.set_option("display.max_columns", None)
pd.set_option("display.width", 200)

INPUT = "data/practice/messy_calls_sample.csv"

# 1. Read the file
calls = pd.read_csv(INPUT)
print("Rows read:", len(calls))
```

Save and run: `python work\clean_calls.py`

You should see:

```text
Rows read: 12
```

> [!NOTE]
> What this does: `INPUT` is a name for the file, written in capital letters at the top so it is easy to find and change later. `len(calls)` counts the rows.

## Step 2. Remove repeated rows

Add to the bottom:

```python
# 2. Remove exact duplicate rows
calls = calls.drop_duplicates()
print("Rows after removing duplicates:", len(calls))
```

Run it. You should see a second line:

```text
Rows after removing duplicates: 11
```

> [!NOTE]
> What this does: `drop_duplicates()` keeps the first copy of any repeated row and removes the others. The new table replaces the old one under the same name.

## Step 3. Fix the wait column

Add to the bottom:

```python
# 3. Turn text numbers into real numbers; anything that is not a number becomes empty
calls["wait_sec"] = pd.to_numeric(calls["wait_sec"], errors="coerce")
print("Calls with no wait time:", calls["wait_sec"].isna().sum())
```

Run it. The new line is:

```text
Calls with no wait time: 1
```

> [!NOTE]
> What this does: `to_numeric` converts text such as `"12"` into the number 12. `errors="coerce"` says "if you cannot convert a value, make it empty instead of crashing". The word `unknown` becomes `NaN`. We did not delete the call, because the rest of the row is still useful.

## Step 4. Set aside the invalid rows

The rule: an answered call must have an agent. Add to the bottom:

```python
# 4. Split off answered calls that have no agent
bad = (calls["outcome"] == "answered") & (calls["agent_id"].isna())
rejects = calls[bad]
clean = calls[~bad]
print("Rejected:", len(rejects))
print("Clean:", len(clean))
```

Run it. The new lines are:

```text
Rejected: 1
Clean: 10
```

> [!NOTE]
> What this does: the first line builds a list of True and False, one per row. A row is True only when the outcome is `answered` and the agent is empty. The `&` means "and". `calls[bad]` picks the True rows, and `calls[~bad]` picks the rest. The `~` means "not". Checking: 11 rows minus 1 rejected leaves 10.

> [!TIP]
> This is like a quality-control line in a factory. Good items go on one belt and faulty items go in a separate bin. Someone later looks in the bin to find out what went wrong. Nothing is thrown away unseen.

## Step 5. Save both files

Add to the bottom:

```python
# 5. Save both files
clean.to_csv("work/clean_calls.csv", index=False)
rejects.to_csv("work/rejects.csv", index=False)
print("Saved work/clean_calls.csv and work/rejects.csv")
```

Run it. The last line is:

```text
Saved work/clean_calls.csv and work/rejects.csv
```

Open `work/rejects.csv` in VS Code. It should contain the header and one row, call 5.

```text
call_id,queue_id,agent_id,arrived_at,wait_sec,talk_sec,outcome
5,3,,2026-10-01 07:45:55,8.0,180,answered
```

> [!NOTE]
> What this does: `to_csv` writes a table to a file. `index=False` stops pandas adding its row numbers as an extra column.

## Step 6. Use the clean data

Add to the bottom:

```python
# 6. A quick check on the clean data
print(clean.groupby("queue_id").size())
print("Average wait:", round(clean["wait_sec"].mean(), 1))
```

Run it. You should see:

```text
queue_id
1    5
2    3
3    1
4    1
dtype: int64
Average wait: 15.6
```

The average works now because the column holds real numbers. The call with the missing wait time is ignored, not counted as zero.

## Check yourself

1. Why do we save rejected rows instead of deleting them?
2. What does `errors="coerce"` do?
3. Why is the script run on the 12-row file first?

<details>
<summary>Answers</summary>

1. Someone has to find out why the rows were bad. Deleting them hides a problem in the source system.
2. It turns values that cannot be converted into empty values instead of stopping with an error.
3. With 12 rows you can check every result by eye. With thousands you could not.

</details>

## Try it yourself

Add a rule: reject any row where `talk_sec` is a negative number. The sample file has none, so you should still see 1 rejected row. Write the line, run it, and confirm.

<details>
<summary>Answer</summary>

Change the `bad` line to:

```python
bad = ((calls["outcome"] == "answered") & (calls["agent_id"].isna())) | (calls["talk_sec"] < 0)
```

The `|` means "or". The output is unchanged: 1 rejected and 10 clean.

</details>

## Done?

Next is [Lab 4C](lab-4c-real-day.md): run your script on a full day.
