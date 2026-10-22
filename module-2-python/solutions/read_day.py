import pandas as pd

pd.set_option("display.max_columns", None)
pd.set_option("display.width", 200)

calls = pd.read_csv("data/calls_2026-10-01.csv")

print("Rows and columns:", calls.shape)
print(calls[["call_id", "queue_id", "wait_sec", "talk_sec", "outcome"]].head())
print(calls["outcome"].value_counts())

queue_names = {1: "Billing", 2: "Claims", 3: "Eligibility", 4: "Provider Line"}
calls["queue_name"] = calls["queue_id"].map(queue_names)
print(pd.crosstab(calls["queue_name"], calls["outcome"]))
print("Longest wait:", calls["wait_sec"].max())
