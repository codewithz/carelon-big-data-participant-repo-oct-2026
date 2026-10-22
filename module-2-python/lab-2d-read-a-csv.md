# Lab 2D: read a data file

Time: 30 minutes

Goal: load a CSV file into Python, look at it, and count calls. First with 20 calls you can check by eye, then with a full day of 1,939 calls.

You need: Labs 2A to 2C finished.

## The tool: pandas

Python on its own can do a lot, but tables are awkward. pandas is an add-on written by other people that makes tables easy. You borrow it with one line, `import pandas as pd`. The `as pd` is a nickname so you type two letters instead of six.

> [!TIP]
> pandas is Excel that you control with typed instructions. A table in pandas is called a DataFrame. Because the instructions are saved in a file, you can run them again tomorrow on new data.

## Part A. Twenty calls

### Step 1. Create the file

Create `work/read_sample.py` and type:

```python
import pandas as pd

# Show every column and use the full width of the terminal
pd.set_option("display.max_columns", None)
pd.set_option("display.width", 200)

calls = pd.read_csv("data/practice/calls_sample.csv")

print(calls)
```

Save and run: `python work\read_sample.py`

You should see a table of 20 rows. The first three rows look like this:

```text
   call_id  queue_id           arrived_at  wait_sec  talk_sec  hold_sec  wrap_sec    outcome
0        1         1  2026-10-01 07:05:10         5       240         0        30   answered
1        2         1  2026-10-01 07:12:44        12       310        20        45   answered
2        3         2  2026-10-01 07:20:03        30       420        60        60   answered
```

If you see `FileNotFoundError`, your terminal is not in the course folder. The prompt should end with the course folder name.

> [!NOTE]
> What this does: `read_csv` opens the file and turns every line into a row of a table, saved in the jar `calls`. The two `set_option` lines tell pandas to show all the columns instead of hiding some with `...`. The numbers on the left (0, 1, 2) are row numbers that pandas adds.

### Step 2. Count the rows

Add these lines at the bottom and run again:

```python
print("Rows:", len(calls))
```

You should see `Rows: 20` at the bottom.

### Step 3. Count calls by outcome

Add:

```python
print(calls["outcome"].value_counts())
```

You should see:

```text
outcome
answered     16
abandoned     4
Name: count, dtype: int64
```

Check it by eye: look at the `outcome` column in the table above. Count the `abandoned` rows. There should be 4.

> [!NOTE]
> What this does: `calls["outcome"]` picks one column. `value_counts` counts how many times each different value appears. This is a "count by group" and you will do the same thing in SQL this afternoon.

### Step 4. Average wait

Add:

```python
print("Average wait:", calls["wait_sec"].mean())
```

You should see `Average wait: 18.8`. Remember that number. In the SQL lab you will get the same answer from the database.

### Step 5. Count calls by queue

Add:

```python
print(calls["queue_id"].value_counts().sort_index())
```

You should see:

```text
queue_id
1    9
2    6
3    3
4    2
Name: count, dtype: int64
```

`sort_index` puts the queue numbers in order. Without it, the biggest group comes first.

If your file does not work, compare it with [solutions/read_sample.py](solutions/read_sample.py).

## Part B. A full day

### Step 6. A new file

Create `work/read_day.py` and type:

```python
import pandas as pd

pd.set_option("display.max_columns", None)
pd.set_option("display.width", 200)

calls = pd.read_csv("data/calls_2026-10-01.csv")

print("Rows and columns:", calls.shape)
print(calls[["call_id", "queue_id", "wait_sec", "talk_sec", "outcome"]].head())
print(calls["outcome"].value_counts())
```

Save and run: `python work\read_day.py`

You should see:

```text
Rows and columns: (1939, 12)
   call_id  queue_id  wait_sec  talk_sec   outcome
0    49177         1         0       328  answered
1    49178         2        20       182  answered
2    49179         3         2       174  answered
3    49180         1         2       235  answered
4    49181         1         4       571  answered
outcome
answered     1772
abandoned     167
Name: count, dtype: int64
```

> [!NOTE]
> What this does: the same steps, a much bigger file. `shape` gives rows and columns. `head` shows the first five rows only, which is the quick way to check a big table loaded properly. The square brackets with a list of names pick a few columns.

### Step 7. Turn queue numbers into names

Numbers like 1 and 2 are hard to read. Use a dictionary to translate them. Add:

```python
queue_names = {1: "Billing", 2: "Claims", 3: "Eligibility", 4: "Provider Line"}
calls["queue_name"] = calls["queue_id"].map(queue_names)
print(pd.crosstab(calls["queue_name"], calls["outcome"]))
```

You should see:

```text
outcome        abandoned  answered
queue_name                        
Billing               50       526
Claims                51       542
Eligibility           35       380
Provider Line         31       324
```

> [!NOTE]
> What this does: `map` goes through every row, looks up its queue number in your dictionary and writes the name into a new column called `queue_name`. `crosstab` draws a grid with queues down the side and outcomes across the top, counting the calls in each box.

These counts include a few duplicate rows. You will find and remove them in Module 4.

### Step 8. Longest wait

Add:

```python
print("Longest wait:", calls["wait_sec"].max())
```

You should see `Longest wait: 142`.

If your file does not work, compare it with [solutions/read_day.py](solutions/read_day.py).

## Stretch (if you finish early)

Average wait for each queue:

```python
print(calls.groupby("queue_name")["wait_sec"].mean().round(1))
```

You should see Billing 15.8, Claims 14.6, Eligibility 15.1 and Provider Line 16.4.

`groupby` sorts the rows into one pile per queue, `mean` averages the wait in each pile.

## Check yourself

1. What does `len(calls)` tell you?
2. What does `value_counts()` do?
3. Why do we use a dictionary to turn queue numbers into names?

<details>
<summary>Answers</summary>

1. The number of rows in the table.
2. It counts how many times each different value appears in a column.
3. A dictionary looks things up by name, so it works as a translation table: give it 1, get "Billing".

</details>

## Done?

You can now load a data file, count things in it and read Python. After the break you will do the same sort of counting in SQL.
