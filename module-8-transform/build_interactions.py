"""One table for all channels: src.calls + src.chats + src.faxes -> interactions.

Run:   python module-8-transform\build_interactions.py   (from the course folder)
Again: the same command (safe, the table is emptied and filled again)

Both tables land in the reporting schema: reporting.interactions and reporting.qa_clean.
"""
import logging
import os
import sys

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, inspect, text

SCHEMA = "reporting"
TABLE = "interactions"
QA_TABLE = "qa_clean"
COLUMNS = ["channel", "source_id", "queue_id", "agent_id", "arrived_at", "answered_at",
           "ended_at", "contact_date", "wait_sec", "handle_sec", "outcome", "is_valid"]

log = logging.getLogger("build")


def setup_logging():
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
        handlers=[logging.StreamHandler(sys.stdout), logging.FileHandler("build.log")],
    )


# ---------- Extract ----------

def extract(conn):
    calls = pd.read_sql(text("SELECT * FROM src.calls"), conn)
    chats = pd.read_sql(text("SELECT chat_id, customer_id, queue_id, agent_id, started_at_local, "
                             "accepted_at_local, ended_at_local, handle_sec, outcome FROM src.chats"), conn)
    faxes = pd.read_sql(text("SELECT * FROM src.faxes"), conn)
    qa = pd.read_sql(text("SELECT * FROM src.qa_scores"), conn)
    return calls, chats, faxes, qa


# ---------- Transform ----------

def to_manila(series):
    """Times that already carry a time zone: show them in Manila time."""
    return pd.to_datetime(series, utc=True).dt.tz_convert("Asia/Manila")


def transform_calls(calls):
    calls = calls.drop_duplicates()                      # Lab 3E: 255 repeated rows
    out = pd.DataFrame({
        "channel": "voice",
        "source_id": calls["call_id"],
        "queue_id": calls["queue_id"],
        "agent_id": calls["agent_id"],
        "arrived_at": to_manila(calls["arrived_at"]),
        "answered_at": to_manila(calls["answered_at"]),
        "ended_at": to_manila(calls["ended_at"]),
        "wait_sec": calls["wait_sec"],
        "handle_sec": calls["talk_sec"] + calls["hold_sec"] + calls["wrap_sec"],
        "outcome": calls["outcome"],
    })
    return out


def transform_chats(chats):
    # Lab 8B: chat times were saved as Manila clock times with no time zone. Say so.
    started = chats["started_at_local"].dt.tz_localize("Asia/Manila")
    accepted = chats["accepted_at_local"].dt.tz_localize("Asia/Manila")
    ended = chats["ended_at_local"].dt.tz_localize("Asia/Manila")
    answered = chats["outcome"] == "answered"
    # Waiting time: until an agent accepted the chat, or until the customer left.
    wait = (accepted.where(answered, ended) - started).dt.total_seconds()
    out = pd.DataFrame({
        "channel": "chat",
        "source_id": chats["chat_id"],
        "queue_id": chats["queue_id"],
        "agent_id": chats["agent_id"],
        "arrived_at": started,
        "answered_at": accepted,
        "ended_at": ended,
        "wait_sec": wait.round().astype(int),
        "handle_sec": chats["handle_sec"].where(answered, 0),
        "outcome": chats["outcome"],
    })
    return out


def transform_faxes(faxes):
    received = to_manila(faxes["received_at"])
    processed = to_manila(faxes["processed_at"])
    out = pd.DataFrame({
        "channel": "fax",
        "source_id": faxes["fax_id"],
        "queue_id": faxes["queue_id"],
        "agent_id": faxes["agent_id"],
        "arrived_at": received,
        "answered_at": processed,
        "ended_at": processed,
        # For a fax the "wait" is the turnaround: received to processed.
        "wait_sec": (processed - received).dt.total_seconds().round().astype(int),
        "handle_sec": 0,
        "outcome": faxes["status"],
    })
    return out


def transform(calls, chats, faxes):
    together = pd.concat([transform_calls(calls), transform_chats(chats), transform_faxes(faxes)],
                         ignore_index=True)
    together["contact_date"] = together["arrived_at"].dt.date
    # Lab 4D: flag rows that cannot be given to an agent, but keep them.
    together["is_valid"] = ~((together["outcome"] == "answered") & together["agent_id"].isna())
    together["agent_id"] = together["agent_id"].astype("Int64")
    return together[COLUMNS]


def transform_qa(qa):
    # Lab 8B: '85%' is text. Strip the % sign and make it a number.
    out = qa[["qa_id", "channel", "interaction_id", "agent_id"]].copy()
    out["evaluated_date"] = to_manila(qa["evaluated_at"]).dt.date
    out["score"] = qa["score_text"].str.rstrip("%").astype(int)
    return out


# ---------- Load ----------

def load(conn, df, table):
    """Empty the table and fill it again. Views built on it keep working."""
    if inspect(conn).has_table(table, schema=SCHEMA):
        conn.execute(text(f"DELETE FROM {SCHEMA}.{table}"))
    df.to_sql(table, conn, schema=SCHEMA, if_exists="append", index=False, chunksize=5000, method="multi")


def main():
    setup_logging()
    load_dotenv()
    url = os.getenv("DATABASE_URL")
    if not url:
        log.error("DATABASE_URL is not set. Copy .env.example to .env and fill it in.")
        sys.exit(1)
    engine = create_engine(url)
    try:
        # One transaction: if anything fails, the old table stays as it was.
        with engine.begin() as conn:
            calls, chats, faxes, qa = extract(conn)
            log.info("Extracted %d calls, %d chats, %d faxes, %d QA scores",
                     len(calls), len(chats), len(faxes), len(qa))
            interactions = transform(calls, chats, faxes)
            qa_clean = transform_qa(qa)
            log.info("Transformed into %d interactions (%d flagged not valid)",
                     len(interactions), (~interactions["is_valid"]).sum())
            load(conn, interactions, TABLE)
            load(conn, qa_clean, QA_TABLE)
            log.info("Loaded %s.%s and %s.%s. Last day: %s",
                     SCHEMA, TABLE, SCHEMA, QA_TABLE, interactions["contact_date"].max())
    except Exception:
        log.exception("Build failed. The transaction was rolled back, so nothing changed.")
        sys.exit(1)


if __name__ == "__main__":
    main()
