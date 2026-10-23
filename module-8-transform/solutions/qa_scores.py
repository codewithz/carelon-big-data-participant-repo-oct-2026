import pandas as pd

pd.set_option("display.width", 200)

qa = pd.read_csv("data/practice/qa_sample.csv")
print(qa[["qa_id", "agent_id", "score_text"]])
print("Type of score_text:", qa["score_text"].dtype)

# Step 3: strip the % sign, then turn the text into a whole number
qa["score"] = qa["score_text"].str.rstrip("%").astype(int)
print(qa[["qa_id", "score_text", "score"]])
print("Type of score:", qa["score"].dtype)
print("Average score:", round(qa["score"].mean(), 1))

# Step 4: the full file
full = pd.read_csv("data/qa_scores.csv")
full["score"] = full["score_text"].str.rstrip("%").astype(int)
print("Rows:", len(full), " Average:", round(full["score"].mean(), 1))
print(full.groupby("channel")["score"].mean().round(1))
