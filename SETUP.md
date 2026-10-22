# Set up your laptop

This takes about 30 minutes. If your trainer has already set up your laptop, skip to [step 6](#6-check-everything).

You need a Windows laptop where you can install programs. If you cannot install programs, tell your trainer before the day.

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

Your trainer will tell you which of these applies to you.

Option A: the trainer runs a shared database server. You only need pgAdmin: download it from pgadmin.org and install it. The trainer gives you the server name, a login (`trainee`) and a password.

Option B: you run your own database. Install PostgreSQL 16 from postgresql.org (it includes pgAdmin). Remember the password you choose for the `postgres` user. Then ask your trainer for the database setup steps.

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
2. Open `.env` and replace the server name and password with the ones your trainer gives you.
3. Save the file and run `python check_setup.py` again. The database line should now say OK.
