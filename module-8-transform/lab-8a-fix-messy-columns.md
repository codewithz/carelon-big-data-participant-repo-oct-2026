# Lab 8A: fix two messy columns

Time: 25 minutes

Goal: turn quality scores like `85%` into numbers you can average, and give chat times the time zone they are missing. Both on 6 rows first, then on real data.

You need: the terminal open in the course folder, with `(.venv)` showing.

## Part A. Scores stored as text

### Step 1. Look at the scores

Create `work/qa_scores.py` and type:

```python
import pandas as pd

pd.set_option("display.width", 200)

qa = pd.read_csv("data/practice/qa_sample.csv")
print(qa[["qa_id", "agent_id", "score_text"]])
print("Type of score_text:", qa["score_text"].dtype)
```

Save and run: `python work\qa_scores.py`

You should see:

```text
   qa_id  agent_id score_text
0      1         6        87%
1      2        25        64%
2      3        21        89%
3      4        26        56%
4      5        34        78%
5      6         5        78%
Type of score_text: str
```

Older versions of pandas print `object` instead of `str`. Both mean text.

Work out the average of these six scores on paper before you go on. Write it down.

### Step 2. Try to average text

Add this line to the bottom, save and run:

```python
print(qa["score_text"].mean())
```

You should see an error that ends with a line like:

```text
TypeError: Cannot perform reduction 'mean' with string dtype
```

The wording differs between pandas versions. The meaning is the same: you cannot average words, and `87%` is a word to the computer.

Delete the line you just added.

### Step 3. Make a number

Add to the bottom:

```python
qa["score"] = qa["score_text"].str.rstrip("%").astype(int)
print(qa[["qa_id", "score_text", "score"]])
print("Type of score:", qa["score"].dtype)
print("Average score:", round(qa["score"].mean(), 1))
```

Save and run. The new lines are:

```text
   qa_id score_text  score
0      1        87%     87
1      2        64%     64
2      3        89%     89
3      4        56%     56
4      5        78%     78
5      6        78%     78
Type of score: int64
Average score: 75.3
```

Compare 75.3 with your answer on paper.

> [!NOTE]
> What this does: `.str.rstrip("%")` removes a `%` from the right-hand end of each value, so `87%` becomes the text `87`. `.astype(int)` turns that text into a whole number. Keep the original `score_text` column next to the new one while you check, so you can see each pair side by side.

### Step 4. The full file

Add to the bottom:

```python
full = pd.read_csv("data/qa_scores.csv")
full["score"] = full["score_text"].str.rstrip("%").astype(int)
print("Rows:", len(full), " Average:", round(full["score"].mean(), 1))
print(full.groupby("channel")["score"].mean().round(1))
```

Save and run. The new lines are:

```text
Rows: 3076  Average: 77.1
channel
chat     77.1
voice    77.1
Name: score, dtype: float64
```

> [!TIP]
> If one value in the full file had been `n/a` or `85 %`, `astype(int)` would stop with a `ValueError` and name the value. That is good. A loud stop is better than a quiet wrong number. Lab 4B used `pd.to_numeric(..., errors="coerce")` instead, which turns bad values into empty ones. Pick the loud way when a bad value should never happen, and the quiet way when you plan to count and report the empties.

## Part B. Times with no time zone

A chat started at `2026-10-01 17:00:56`. Where? If that is Manila time, it is 5 in the afternoon. If a program guesses London time (UTC), it thinks the chat started at 5 in the afternoon in London, which is 1 in the morning of 2 October in Manila. A time with no time zone means whatever the next program guesses.

The chat system saved Manila clock times and did not say so. Calls and faxes did say so, with `+08` at the end.

### Step 5. Look at the times

Create `work/chat_times.py` and type:

```python
import pandas as pd

pd.set_option("display.width", 200)

chats = pd.read_csv("data/practice/chats_sample.csv", parse_dates=["started_at_local"])
print(chats[["chat_id", "started_at_local"]])
print("Time zone:", chats["started_at_local"].dt.tz)
```

Save and run: `python work\chat_times.py`

You should see:

```text
   chat_id    started_at_local
0    14902 2026-10-01 08:07:15
1    14903 2026-10-01 08:12:44
2    14929 2026-10-01 09:03:01
3    15109 2026-10-01 12:01:11
4    15318 2026-10-01 17:00:56
5    15427 2026-10-01 20:02:16
Time zone: None
```

> [!NOTE]
> What this does: `parse_dates` tells pandas to read that column as dates and times instead of text. `.dt.tz` asks for the time zone. `None` means there is none.

### Step 6. The wrong guess

Many servers and cloud tools assume UTC (London winter time) when no time zone is given. Add to the bottom:

```python
wrong = chats["started_at_local"].dt.tz_localize("UTC").dt.tz_convert("Asia/Manila")
right = chats["started_at_local"].dt.tz_localize("Asia/Manila")
print(pd.DataFrame({"chat_id": chats["chat_id"], "wrong": wrong, "right": right}))
```

Save and run. The new lines are:

```text
   chat_id                     wrong                     right
0    14902 2026-10-01 16:07:15+08:00 2026-10-01 08:07:15+08:00
1    14903 2026-10-01 16:12:44+08:00 2026-10-01 08:12:44+08:00
2    14929 2026-10-01 17:03:01+08:00 2026-10-01 09:03:01+08:00
3    15109 2026-10-01 20:01:11+08:00 2026-10-01 12:01:11+08:00
4    15318 2026-10-02 01:00:56+08:00 2026-10-01 17:00:56+08:00
5    15427 2026-10-02 04:02:16+08:00 2026-10-01 20:02:16+08:00
```

Look at the last two rows of the `wrong` column. Two chats from the afternoon of 1 October have moved to the early morning of 2 October.

> [!NOTE]
> What this does: `tz_localize` attaches a time zone to a time that has none, without changing the clock reading. `tz_convert` then shows the same moment in another time zone. The wrong line says "this was 17:00 in London", which is 01:00 the next day in Manila. The right line says "this was 17:00 in Manila". Only `tz_localize("Asia/Manila")` is the fix. The `wrong` line is there to show you what happens to anyone who skips this step.

### Step 7. What it does to a real day

Add to the bottom:

```python
day = pd.read_csv("data/chats_2026-10-01.csv", parse_dates=["started_at_local"])
wrong_day = day["started_at_local"].dt.tz_localize("UTC").dt.tz_convert("Asia/Manila").dt.date
right_day = day["started_at_local"].dt.tz_localize("Asia/Manila").dt.date
print("Wrong guess, chats per day:")
print(wrong_day.value_counts().sort_index())
print("Right fix, chats per day:")
print(right_day.value_counts().sort_index())
```

Save and run. The new lines are:

```text
Wrong guess, chats per day:
started_at_local
2026-10-01    374
2026-10-02    182
Name: count, dtype: int64
Right fix, chats per day:
started_at_local
2026-10-01    556
Name: count, dtype: int64
```

With the wrong guess, every chat that started at 16:00 or later lands on the next day. That is 182 of 556 chats, one in three. A daily chat report built that way would be wrong every single day, and nobody would get an error message.

## Check yourself

1. Why does `qa["score_text"].mean()` fail?
2. What is the difference between `tz_localize` and `tz_convert`?
3. Which chats move to the wrong day with the UTC guess, and why those?
4. Why keep `score_text` next to `score` while you check?

<details>
<summary>Answers</summary>

1. The column is text. `87%` is a word to the computer, not a number.
2. `tz_localize` says which time zone a time was written in, without changing it. `tz_convert` shows an existing moment in a different time zone.
3. Chats from 16:00 onwards. Manila is 8 hours ahead of UTC, and 16:00 plus 8 hours is midnight.
4. So you can compare each old value with its new value by eye and spot a bad conversion.

</details>

## Done?

The same two fixes are inside the script you run in [Lab 8B](lab-8b-one-table.md). The solutions for this lab are in `module-8-transform/solutions/`.
