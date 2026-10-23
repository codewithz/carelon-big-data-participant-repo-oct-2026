"""Challenge 8C solution: a small pipeline written from scratch.
src.qa_scores -> reporting.qa_mine, then compare with solution.qa_clean.
"""
import os

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, inspect, text

load_dotenv()
engine = create_engine(os.getenv("DATABASE_URL"))

with engine.begin() as conn:
    # Extract
    qa = pd.read_sql(text("SELECT * FROM src.qa_scores"), conn)
    print("Extracted", len(qa), "scores")

    # Transform
    out = qa[["qa_id", "channel", "interaction_id", "agent_id"]].copy()
    out["evaluated_date"] = (pd.to_datetime(qa["evaluated_at"], utc=True)
                             .dt.tz_convert("Asia/Manila").dt.date)
    out["score"] = qa["score_text"].str.rstrip("%").astype(int)
    print("Average score:", round(out["score"].mean(), 1))

    # Load: empty the table if it is there, then add the rows
    if inspect(conn).has_table("qa_mine", schema="reporting"):
        conn.execute(text("DELETE FROM reporting.qa_mine"))
    out.to_sql("qa_mine", conn, schema="reporting", if_exists="append", index=False)
    print("Loaded", len(out), "rows into reporting.qa_mine")

    # Check
    diff = conn.execute(text("""
        SELECT count(*) FROM (SELECT * FROM reporting.qa_mine
                              EXCEPT ALL
                              SELECT * FROM solution.qa_clean) AS d
    """)).scalar()
    print("Rows that differ from solution.qa_clean:", diff)
