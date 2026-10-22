"""Daily agent performance summary: PostgreSQL src.calls -> reporting.agent_daily.

Run:   python module-5-etl\agent_daily_etl.py   (from the course folder)
Again: the same command (safe, the result does not change)
Reset: python module-5-etl\agent_daily_etl.py --reset

Each run loads only the days after the watermark, so a second run finds nothing new.
"""
import argparse
import logging
import os
import sys
from datetime import date, timedelta

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

JOB_NAME = "agent_daily"
FIRST_DAY = date(2026, 9, 1)  # the day before the first day of data

log = logging.getLogger("etl")


def setup_logging():
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
        handlers=[logging.StreamHandler(sys.stdout), logging.FileHandler("etl.log")],
    )


def get_watermark(conn):
    row = conn.execute(
        text("SELECT last_loaded_date FROM reporting.etl_watermark WHERE job_name = :j"),
        {"j": JOB_NAME},
    ).fetchone()
    return row[0] if row else FIRST_DAY


def extract(conn, start_day, end_day):
    """Answered calls with an agent, for start_day up to and including end_day (Manila time)."""
    sql = text("""
        SELECT DISTINCT call_id, agent_id, talk_sec, hold_sec, wrap_sec,
               (arrived_at AT TIME ZONE 'Asia/Manila')::date AS summary_date
        FROM src.calls
        WHERE outcome = 'answered'
          AND agent_id IS NOT NULL
          AND (arrived_at AT TIME ZONE 'Asia/Manila')::date BETWEEN :start AND :end
    """)
    return pd.read_sql(sql, conn, params={"start": start_day, "end": end_day})


def transform(calls):
    """One row per agent per day."""
    calls = calls.copy()
    calls["handle_sec"] = calls["talk_sec"] + calls["hold_sec"] + calls["wrap_sec"]
    summary = (
        calls.groupby(["agent_id", "summary_date"])
        .agg(
            calls_handled=("call_id", "count"),
            aht_sec=("handle_sec", "mean"),  # Lab 5B asks you to change "mean" on this line
            longest_call_sec=("handle_sec", "max"),
        )
        .reset_index()
    )
    summary["aht_sec"] = summary["aht_sec"].round().astype(int)
    return summary


UPSERT = text("""
    INSERT INTO reporting.agent_daily
        (agent_id, summary_date, calls_handled, aht_sec, longest_call_sec)
    VALUES (:agent_id, :summary_date, :calls_handled, :aht_sec, :longest_call_sec)
    ON CONFLICT (agent_id, summary_date) DO UPDATE SET
        calls_handled    = EXCLUDED.calls_handled,
        aht_sec          = EXCLUDED.aht_sec,
        longest_call_sec = EXCLUDED.longest_call_sec,
        loaded_at        = now()
""")

SET_WATERMARK = text("""
    INSERT INTO reporting.etl_watermark (job_name, last_loaded_date) VALUES (:j, :d)
    ON CONFLICT (job_name) DO UPDATE SET last_loaded_date = EXCLUDED.last_loaded_date
""")


def load(conn, summary, new_watermark):
    rows = summary.to_dict("records")
    if rows:
        conn.execute(UPSERT, rows)
    conn.execute(SET_WATERMARK, {"j": JOB_NAME, "d": new_watermark})


def run(engine):
    # engine.begin() opens one transaction: if anything fails, nothing is saved.
    with engine.begin() as conn:
        watermark = get_watermark(conn)
        latest = conn.execute(
            text("SELECT max((arrived_at AT TIME ZONE 'Asia/Manila')::date) FROM src.calls")
        ).scalar()
        if latest is None or latest <= watermark:
            log.info("Nothing new after %s. Done.", watermark)
            return 0
        start_day = watermark + timedelta(days=1)
        log.info("Extracting %s to %s", start_day, latest)
        calls = extract(conn, start_day, latest)
        log.info("Extracted %d calls", len(calls))
        summary = transform(calls)
        log.info("Transformed into %d agent-day rows", len(summary))
        load(conn, summary, latest)
        log.info("Loaded. Watermark is now %s", latest)
        return len(summary)


def reset(engine):
    with engine.begin() as conn:
        conn.execute(text("DELETE FROM reporting.agent_daily"))
        conn.execute(text("DELETE FROM reporting.etl_watermark WHERE job_name = :j"), {"j": JOB_NAME})
    log.info("Reset: agent_daily emptied and watermark removed")


def main():
    setup_logging()
    parser = argparse.ArgumentParser()
    parser.add_argument("--reset", action="store_true", help="empty the target and start again")
    args = parser.parse_args()

    load_dotenv()
    url = os.getenv("DATABASE_URL")
    if not url:
        log.error("DATABASE_URL is not set. Copy .env.example to .env and fill it in.")
        sys.exit(1)
    engine = create_engine(url)
    try:
        if args.reset:
            reset(engine)
        else:
            run(engine)
    except Exception:
        log.exception("ETL failed. The transaction was rolled back, so no partial data was saved.")
        sys.exit(1)


if __name__ == "__main__":
    main()
