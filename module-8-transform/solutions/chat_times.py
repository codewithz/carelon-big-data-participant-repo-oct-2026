import pandas as pd

pd.set_option("display.width", 200)

chats = pd.read_csv("data/practice/chats_sample.csv", parse_dates=["started_at_local"])
print(chats[["chat_id", "started_at_local"]])
print("Time zone:", chats["started_at_local"].dt.tz)

# Step 6: the wrong guess. A server that assumes UTC, shown in Manila time
wrong = chats["started_at_local"].dt.tz_localize("UTC").dt.tz_convert("Asia/Manila")
# Step 7: the right fix. These are Manila clock times, so say so
right = chats["started_at_local"].dt.tz_localize("Asia/Manila")
print(pd.DataFrame({"chat_id": chats["chat_id"], "wrong": wrong, "right": right}))

# Step 8: the full day
day = pd.read_csv("data/chats_2026-10-01.csv", parse_dates=["started_at_local"])
wrong_day = day["started_at_local"].dt.tz_localize("UTC").dt.tz_convert("Asia/Manila").dt.date
right_day = day["started_at_local"].dt.tz_localize("Asia/Manila").dt.date
print("Wrong guess, chats per day:")
print(wrong_day.value_counts().sort_index())
print("Right fix, chats per day:")
print(right_day.value_counts().sort_index())
