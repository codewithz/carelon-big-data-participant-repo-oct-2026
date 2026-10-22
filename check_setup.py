"""Checks that your laptop is ready for the course.

Run it from the course folder:  python check_setup.py
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

# 1. Python version
version = sys.version_info
report(version >= (3, 10), f"Python {version.major}.{version.minor}.{version.micro}",
       "Install Python 3.12 from python.org and tick 'Add python.exe to PATH'.")

# 2. Packages
for module, install in [("pandas", "pandas"), ("sqlalchemy", "sqlalchemy"),
                        ("psycopg", '"psycopg[binary]"'), ("dotenv", "python-dotenv")]:
    try:
        importlib.import_module(module)
        report(True, f"Package {module} is installed")
    except ImportError:
        report(False, f"Package {module} is not installed",
                   f"Run: pip install {install}  (first check your prompt starts with (.venv); if not, run .\\.venv\\Scripts\\Activate.ps1)")

# 3. Course files
needed = ["data/practice/calls_sample.csv", "data/practice/messy_calls_sample.csv",
          "data/calls_2026-10-01.csv", "data/calls.csv", "module-5-etl/agent_daily_etl.py"]
for name in needed:
    report((root / name).exists(), f"File {name} is present",
           "Check you extracted the whole ZIP and that you run this from the course folder.")

# 4. Settings file
env_file = root / ".env"
report(env_file.exists(), ".env settings file exists",
       "Copy .env.example to .env and fill in the values from your trainer (see SETUP.md step 7).")

# 5. Database connection
url = None
try:
    from dotenv import load_dotenv
    load_dotenv(env_file)
    url = os.getenv("DATABASE_URL")
except ImportError:
    pass
report(bool(url), "DATABASE_URL is set in .env", "Open .env and check the line starting DATABASE_URL.")
if url:
    try:
        from sqlalchemy import create_engine, text
        with create_engine(url).connect() as conn:
            calls = conn.execute(text("select count(*) from src.calls")).scalar()
            practice = conn.execute(text("select count(*) from practice.calls")).scalar()
        report(True, f"Database connection works ({calls} calls, {practice} practice calls)")
        report(calls == 51363 and practice == 20, "Database has the expected data",
               "Ask your trainer: the numbers should be 51363 and 20.")
    except Exception as error:  # show the first line of the problem, not a wall of text
        first_line = str(error).strip().splitlines()[0][:160]
        report(False, "Database connection works", f"{first_line}")

print()
if problems:
    print(f"{problems} thing(s) to fix. Fix them and run this again.")
else:
    print("All good. You are ready.")
