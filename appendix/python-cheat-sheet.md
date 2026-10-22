# Python and pandas cheat sheet

## Running things

| You want | Type |
|---|---|
| Run a script | `python work\my_script.py` |
| Open the Python prompt | `python` (leave with `exit()`) |
| Switch on the environment | `.venv\Scripts\Activate.ps1` |
| Check your setup | `python check_setup.py` |

## Basics

```python
name = "Billing"          # text
calls = 573               # whole number
rate = 7.4                # decimal
queues = ["Billing", "Claims"]            # list
sla = {"Billing": 20, "Web Chat": 60}     # dictionary: look things up by name
print(queues[0])          # first item: Billing
print(sla["Billing"])     # 20
for q in queues:          # do something for each item
    print(q)
```

## pandas

```python
import pandas as pd

calls = pd.read_csv("data/practice/calls_sample.csv")   # read a file
len(calls)                                # number of rows
calls.shape                               # (rows, columns)
calls.head()                              # first 5 rows
calls.dtypes                              # kind of data in each column
calls.isna().sum()                        # empty values per column
calls.duplicated().sum()                  # number of repeated rows
calls = calls.drop_duplicates()           # remove repeated rows
```

| You want | Write |
|---|---|
| Pick rows | `calls[calls["outcome"] == "answered"]` |
| Both conditions | `calls[(calls["outcome"] == "answered") & (calls["wait_sec"] > 20)]` |
| Opposite of a mask | `calls[~mask]` |
| New column | `calls["handle_sec"] = calls["talk_sec"] + calls["hold_sec"]` |
| Text column to numbers | `pd.to_numeric(calls["wait_sec"], errors="coerce")` |
| Count by group | `calls.groupby("queue_id").size()` |
| Average by group | `calls.groupby("queue_id")["wait_sec"].mean()` |
| Count values | `calls["outcome"].value_counts()` |
| Save to a file | `calls.to_csv("work/out.csv", index=False)` |

## Common errors

| Message | Meaning |
|---|---|
| `FileNotFoundError` | Wrong folder or wrong file name. Your terminal must be in the course folder |
| `KeyError: 'wait'` | The column name is spelled differently. Check `calls.columns` |
| `IndentationError` | Lines inside a block must start with the same number of spaces |
| `ModuleNotFoundError: No module named 'pandas'` | The environment is off. Your prompt must start with `(.venv)` |
| `TypeError` about `str` | A number column holds text. Use `pd.to_numeric` |
