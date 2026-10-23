# Set up your VM

Each of you has your own Windows training VM. PostgreSQL 16, pgAdmin and Power BI Desktop are already on it. This page gets the course files, Python and the database ready. It takes about 30 minutes. If your trainer has already done it, skip to [step 6](#6-check-everything).

## 1. Get the course files

1. On the GitHub page for this course, click the green Code button, then Download ZIP.
2. Right-click the downloaded file and choose Extract All.
3. Move the extracted folder to `C:\training` so the path looks like `C:\training\contact-centre-data-day1`. Use a short path with no spaces. Do not put it in OneDrive.

## 2. Install Python

1. Go to python.org/downloads and download Python 3.12 (3.13 also works).
2. Run the installer. On the first screen, tick **Add python.exe to PATH**, then click Install Now.
3. Open Windows Terminal and type:

   ```powershell
   python --version
   ```

   You should see `Python 3.12.x` or similar. If Windows opens the Microsoft Store instead, see [troubleshooting](appendix/troubleshooting.md).

## 3. Install VS Code

1. Go to code.visualstudio.com and install VS Code with the default options.
2. Open VS Code, click the Extensions icon on the left, search for **Python** (from Microsoft) and click Install.

## 4. Install the database tools

Each of you has your own training VM with PostgreSQL 16 and pgAdmin already installed. Nobody else uses your database, so nothing you do can break anyone else's work.

The login on every VM is the user `postgres` with the password `admin`. That is fine for a training VM that only you use. Never use a password like that at work.

Build the course database once, before Day 1. Follow "The quick way" in [data/db/README.md](data/db/README.md). It takes a few seconds and ends with a small table showing 51363 and 20. If you ever damage the data, run the same script again: it puts everything back as it was at the start of Day 1.

## 5. Install the Python packages

1. Open VS Code and choose File, then Open Folder, and pick the course folder.
2. Choose Terminal, then New Terminal. The prompt should end with the course folder name.
3. Run these one at a time:

   ```powershell
   python -m venv .venv
   .\.venv\Scripts\Activate.ps1
   pip install pandas sqlalchemy "psycopg[binary]" python-dotenv
   ```

   After the second command the prompt starts with `(.venv)`. If you see an error about scripts being disabled, run `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`, answer Y, and try the second command again.
4. VS Code may ask "We noticed a new environment. Do you want to select it?" Click Yes.

## 6. Check everything

In the same terminal, with `(.venv)` showing, run:

```powershell
python check_setup.py
```

You should see a list of checks. Each line starts with OK or MISSING. Fix anything marked MISSING using the hint on the same line, then run it again. When every line says OK, you are ready.

## 7. Create your settings file

The database password lives in a file called `.env` so it never appears in your code.

1. In VS Code, find `.env.example` in the left panel. Right-click it and choose Copy, then right-click empty space and choose Paste. Rename the copy to `.env`.
2. Open `.env` and check the line reads `DATABASE_URL=postgresql+psycopg://postgres:admin@localhost:5432/contact_centre`. On the training VMs nothing needs changing.
3. Save the file and run `python check_setup.py` again. The database line should now say OK.

## Before Day 2

Day 2 needs no new installs in Python. It adds Power BI Desktop, which is already on your VM.

1. **Get the Day 2 files.** Download the course ZIP again from GitHub and extract it over your course folder, or ask your trainer for the new folders (`module-7` to `module-11`, `check_day2.py`, and the new files in `data/practice/`). Your `.env` and `work` folder are not in the ZIP, so they are kept.
2. **Power BI Desktop.** It is already installed on your VM. Open it once before the day and close any sign-in box. Lab 10A starts with a version check.
3. **Your database.** Nothing to do before the day. Lab 7A runs one script, `data/db/day2_setup.sql`, and then `python check_day2.py`. Every line should say OK.
