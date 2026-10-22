import pandas as pd

# Show every column and use the full width of the terminal
pd.set_option("display.max_columns", None)
pd.set_option("display.width", 200)

calls = pd.read_csv("data/practice/calls_sample.csv")

print(calls)
print("Rows:", len(calls))
print(calls["outcome"].value_counts())
print("Average wait:", calls["wait_sec"].mean())
print(calls["queue_id"].value_counts().sort_index())
