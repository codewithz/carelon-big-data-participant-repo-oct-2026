# Lab 4C: clean a full day

Time: 25 minutes

Goal: run the script you wrote on 1,939 real calls and check the result.

You need: Lab 4B finished, with `work/clean_calls.py` working.

The file `data/calls_2026-10-01.csv` is one full day of calls. It has more columns than the sample (customer, answer time, hold time), but the same kinds of problems. Your script does not need to change, except for the name of the file.

## Step 1. Look at the file first

Do not skip this. Open `data/calls_2026-10-01.csv` in VS Code and scroll through the first 20 rows. You will see columns such as `call_id`, `queue_id`, `agent_id`, `arrived_at`, `wait_sec` and `outcome`. Some rows have an empty `agent_id`.

The file is too long to check by eye. That is why the script exists.

## Step 2. Point the script at the new file

Open `work/clean_calls.py`. Change this line:

```python
INPUT = "data/practice/messy_calls_sample.csv"
```

to:

```python
INPUT = "data/calls_2026-10-01.csv"
```

Save and run: `python work\clean_calls.py`

You should see:

```text
Rows read: 1939
Rows after removing duplicates: 1932
Calls with no wait time: 0
Rejected: 4
Clean: 1928
Saved work/clean_calls.csv and work/rejects.csv
queue_id
1    571
2    591
3    413
4    353
dtype: int64
Average wait: 15.4
```

> [!NOTE]
> What this does: the same six steps ran on a bigger file. Seven rows were exact repeats. Four answered calls had no agent and were put in the rejects file. The remaining 1,928 are safe to report on. Nothing needed changing in the code, only the file name. That is the point of writing a script instead of fixing the file by hand.

## Step 3. Look at the rejects

Open `work/rejects.csv` in VS Code. It should have a header and 4 rows. Look at the `outcome` column and the `agent_id` column.

You should see 4 rows, all `answered`, all with an empty `agent_id`. In a real job you would send this file to whoever looks after the phone system and ask why those calls have no agent.

## Step 4. Compare with SQL

In Lab 3E you counted calls per queue in the database. Billing had 573 calls on 1 October. Your clean file has 571 for queue 1, which is Billing.

Why are they different by 2? Think before you read on.

<details>
<summary>Answer</summary>

Two of the four rejected calls were Billing calls. The SQL view removed repeated rows, but it did not remove answered calls with no agent. The Python script removes both. Two cleaning rules give two slightly different counts, which is why a team has to agree on its rules before it publishes numbers.

</details>

## Step 5. Count outcomes

Add to the bottom of `work/clean_calls.py`:

```python
print(clean["outcome"].value_counts())
```

Save and run. The last lines of the output are:

```text
outcome
answered     1763
abandoned     165
Name: count, dtype: int64
```

1,763 plus 165 is 1,928, the clean row count.

> [!NOTE]
> What this does: `value_counts()` counts how many times each different value appears in a column.

## Check yourself

1. What would happen to a report if the 7 repeated calls stayed in?
2. Which line did you change to switch from the sample to the full day?
3. The cleaned file has 1,928 rows. Where did the other 11 go?

<details>
<summary>Answers</summary>

1. The call counts would be too high by 7, and averages would be slightly off.
2. The `INPUT = ...` line.
3. 7 were repeats that were removed, and 4 were answered calls with no agent that went to `rejects.csv`.

</details>

## Try it yourself

Print the average wait for each queue. Hint: use `clean.groupby("queue_id")["wait_sec"].mean()`.

<details>
<summary>Answer</summary>

```python
print(clean.groupby("queue_id")["wait_sec"].mean().round(1))
```

You should see 15.8 for queue 1, 14.6 for queue 2, 15.1 for queue 3 and 16.4 for queue 4.

</details>

## Done?

You can now clean a file and prove the result. Next is [Module 5](../module-5-etl/README.md): turn a script like this into a process that runs every day.
