# Lab 4A: find the problems by looking

Time: 20 minutes

Goal: open a messy file and spot three problems before you write any cleaning code.

You need: Module 2 finished, and a terminal open in the course folder with `(.venv)` showing.

The file `data/practice/messy_calls_sample.csv` has 12 calls. It looks like a normal file, but three things are wrong with it. Always look before you clean.

## Step 1. Read the file

Create `work/inspect_calls.py` and type:

```python
import pandas as pd

pd.set_option("display.max_columns", None)
pd.set_option("display.width", 200)

calls = pd.read_csv("data/practice/messy_calls_sample.csv")

print(calls)
print(calls.shape)
```

Save and run: `python work\inspect_calls.py`

You should see:

```text
    call_id  queue_id  agent_id           arrived_at wait_sec  talk_sec    outcome
0         1         1      11.0  2026-10-01 07:05:10        5       240   answered
1         2         1      12.0  2026-10-01 07:12:44       12       310   answered
2         3         2      13.0  2026-10-01 07:20:03       30       420   answered
3         3         2      13.0  2026-10-01 07:20:03       30       420   answered
4         4         1       NaN  2026-10-01 07:31:18        3         0  abandoned
5         5         3       NaN  2026-10-01 07:45:55        8       180   answered
6         6         2      14.0  2026-10-01 08:02:09  unknown         0  abandoned
7         7         1      11.0  2026-10-01 08:10:30       18       275   answered
8         8         4      15.0  2026-10-01 08:22:41       22       350   answered
9         9         2      12.0  2026-10-01 08:40:12       10       200   answered
10       10         1      13.0  2026-10-01 08:55:00       25       500   answered
11       11         3      14.0  2026-10-01 09:03:27       15       260   answered
(12, 7)
```

> [!NOTE]
> What this does: `print(calls)` shows the whole table. `calls.shape` is a pair of numbers: rows, then columns. The agent numbers show as `11.0` instead of `11` because a column that has an empty value (`NaN`) is stored with decimals in pandas.

## Step 2. Find the problems with your eyes

Look at the table above for two minutes. Write down anything that looks wrong. Then open the hint.

<details>
<summary>Hint</summary>

* Rows 2 and 3 are identical.
* Row 5 is an answered call with no agent.
* Row 6 has the word `unknown` where a wait time should be.

</details>

Row 4 is also missing an agent, but that is normal. A caller who hung up was never connected to an agent.

## Step 3. Ask Python to confirm

Add these lines to the bottom of `work/inspect_calls.py`:

```python
print("Repeated rows:", calls.duplicated().sum())
print(calls.isna().sum())
print(calls.dtypes)
```

Save and run again. The new lines at the bottom of the output are:

```text
Repeated rows: 1
call_id       0
queue_id      0
agent_id      2
arrived_at    0
wait_sec      0
talk_sec      0
outcome       0
dtype: int64
call_id         int64
queue_id        int64
agent_id      float64
arrived_at        str
wait_sec          str
talk_sec        int64
outcome           str
dtype: object
```

> [!NOTE]
> What this does: `duplicated()` marks a row True if an earlier row is identical, and `.sum()` counts the True values. `isna().sum()` counts the empty values in each column. `dtypes` shows what kind of thing each column holds.

> [!NOTE]
> Your pandas version may print `object` instead of `str` for text columns. They mean the same thing here.

Look at the `wait_sec` line. It says `str`, which means text. A column of numbers would say `int64`. One bad value, `unknown`, turned the whole column into text. That is the problem to fix.

## Step 4. See what text does to a calculation

Add one more line:

```python
print(calls["wait_sec"].mean())
```

Run it. You should see an error that ends with:

```text
TypeError: Cannot perform reduction 'mean' with string dtype
```

This error is expected. Text cannot be averaged. Delete the line again, or put a `#` at the start to switch it off.

> [!NOTE]
> What this does: it asks for the average of the wait column, and Python refuses because part of the column is words.

## Check yourself

1. How many problems are in the file, and what are they?
2. Why is the missing agent on call 4 fine but on call 5 a problem?
3. What does `NaN` mean?

<details>
<summary>Answers</summary>

1. Three: a repeated row, an answered call with no agent, and a text value in the wait column.
2. Call 4 was abandoned, so no agent ever took it. Call 5 was answered, so some agent must have handled it and the record is incomplete.
3. Not a number. It is how pandas shows an empty value.

</details>

## Done?

Next is [Lab 4B](lab-4b-clean.md): fix the three problems.
