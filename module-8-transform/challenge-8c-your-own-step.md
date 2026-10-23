# Challenge 8C: write a pipeline step from scratch

Time: 30 minutes. A challenge: fewer instructions, more thinking. Do it after Lab 8B if you have time, or at home.

Goal: write a complete extract, transform, load and check for one table, from an empty file, without copying `build_interactions.py`. Then break it on purpose and watch the check catch it.

You need: Lab 8B finished.

## The job

Build `reporting.qa_mine`: every quality score, with the score as a number and the date it was given in Manila time. It must match `solution.qa_clean` exactly, column for column:

| Column | Type | From |
|---|---|---|
| `qa_id` | whole number | `src.qa_scores.qa_id` |
| `channel` | text | `src.qa_scores.channel` |
| `interaction_id` | whole number | `src.qa_scores.interaction_id` |
| `agent_id` | whole number | `src.qa_scores.agent_id` |
| `evaluated_date` | date | the Manila date of `evaluated_at` |
| `score` | whole number | `score_text` without the `%` |

## Step 1. Plan it

Create `work/qa_pipeline.py`. Before any code, write four comment lines, one per step, saying what each step will do:

```python
# Extract:
# Transform:
# Load:
# Check:
```

Fill in the words after each colon. Then write the code for each step under its comment.

## Step 2. Extract

Connect with the `DATABASE_URL` in `.env` and read `src.qa_scores` into a DataFrame. Print the number of rows: 3,076.

<details>
<summary>Hint</summary>

The first lines of `build_interactions.py` and `agent_daily_etl.py` both do this: `load_dotenv()`, `os.getenv("DATABASE_URL")`, `create_engine(...)`, then `pd.read_sql(text("SELECT ..."), conn)` inside `with engine.begin() as conn:`.

</details>

## Step 3. Transform

Make a new DataFrame with the six columns in the table above, in that order. Print the average score: 77.1.

<details>
<summary>Hint: the date</summary>

`evaluated_at` arrives with a time zone. Convert it to Manila first, then keep the date:

```python
pd.to_datetime(qa["evaluated_at"], utc=True).dt.tz_convert("Asia/Manila").dt.date
```

</details>

## Step 4. Load

Write the DataFrame to `reporting.qa_mine`. Make it repeat-safe: running the script twice must leave 3,076 rows, not 6,152.

<details>
<summary>Hint</summary>

Do what `load` in `build_interactions.py` does: if the table exists, `DELETE FROM` it, then `to_sql(..., schema="reporting", if_exists="append", index=False)`.

</details>

## Step 5. Check

Add a check at the end of the script that counts the rows of `reporting.qa_mine` that are not in `solution.qa_clean`, using `EXCEPT ALL` as in Lab 8B step 7, and prints the number.

Run the script twice. Both times you should see:

```text
Extracted 3076 scores
Average score: 77.1
Loaded 3076 rows into reporting.qa_mine
Rows that differ from solution.qa_clean: 0
```

## Step 6. Break it on purpose

Change the date line so it skips the Manila step: remove `.dt.tz_convert("Asia/Manila")`. Run again.

You should see `Rows that differ from solution.qa_clean: 67`. Sixty-seven scores were given before 08:00 Manila time, which is still the previous day in UTC. Nothing crashed, and the average score is still 77.1. Only the check noticed.

Put the line back and run once more, so you are at 0.

## Check yourself

1. Which step would you have to change if the QA system started sending `85.5%`?
2. Why does the average score not change when the dates are wrong?
3. Why is the check part of the script, and not something you run by hand afterwards?

<details>
<summary>Answers</summary>

1. Transform: `astype(int)` would stop with an error on `85.5`. You would use `astype(float)`, and decide how to round.
2. The average uses only the score column. Wrong dates move scores to the wrong day, so daily numbers change, but the total does not.
3. A check that runs every time catches the day something changes. A check you have to remember gets forgotten.

</details>

The finished script is in `solutions/challenge_qa_pipeline.py`. Look only after you have tried.
