"""Checks that your VM is ready for Day 2.

Run it from the course folder:  python check_day2.py
Each line starts with OK or MISSING. A MISSING line tells you what to do.
"""
import importlib
import os
import sys
from pathlib import Path

problems = 0


def report(ok, message, hint=""):
    global problems
    if ok:
        print("OK       " + message)
    else:
        problems += 1
        print("MISSING  " + message)
        if hint:
            print("         -> " + hint)


root = Path(__file__).resolve().parent

# 1. Packages (the same as Day 1)
for module, install in [("pandas", "pandas"), ("sqlalchemy", "sqlalchemy"),
                        ("psycopg", '"psycopg[binary]"'), ("dotenv", "python-dotenv")]:
    try:
        importlib.import_module(module)
        report(True, f"Package {module} is installed")
    except ImportError:
        report(False, f"Package {module} is not installed",
               f"Run: pip install {install}  (first check your prompt starts with (.venv))")

# 2. Day 2 files
needed = ["module-8-transform/build_interactions.py", "data/practice/qa_sample.csv",
          "data/practice/chats_sample.csv", "module-10-powerbi/data/kpi_queue_daily.csv"]
for name in needed:
    report((root / name).exists(), f"File {name} is present",
           "Get the Day 2 files: see SETUP.md, Before Day 2.")

# 3. The login in .env
url = None
try:
    from dotenv import load_dotenv
    load_dotenv(root / ".env")
    url = os.getenv("DATABASE_URL")
except ImportError:
    pass
report(bool(url), "DATABASE_URL is set in .env", "Open .env and check the line starting DATABASE_URL.")
if url:
    try:
        from sqlalchemy import create_engine, text
        with create_engine(url).connect() as conn:
            user, db = conn.execute(text("SELECT current_user, current_database()")).one()
            report(db == "contact_centre", f"Connected as {user} to {db}",
                   "Check the end of the DATABASE_URL line in .env says /contact_centre.")
            days = conn.execute(text(
                "SELECT count(DISTINCT (arrived_at AT TIME ZONE 'Asia/Manila')::date) FROM src.calls")).scalar()
            report(days == 30, f"src holds {days} days" + (" (2 September to 1 October)" if days == 30 else ""),
                   "Run data/db/day2_setup.sql in pgAdmin (Lab 7A step 1). It removes the extra day.")
            views = conn.execute(text(
                "SELECT count(*) FROM information_schema.views WHERE table_schema = 'solution'")).scalar()
            report(views == 9, "The finished copies in solution are there",
                   "Run data/db/day2_setup.sql in pgAdmin (Lab 7A step 1).")
    except Exception as error:  # show the first line of the problem, not a wall of text
        first_line = str(error).strip().splitlines()[0][:160]
        report(False, "Database connection works", first_line)

print()
if problems:
    print(f"{problems} thing(s) to fix. Fix them and run this again.")
else:
    print("All good. You are ready for Day 2.")
