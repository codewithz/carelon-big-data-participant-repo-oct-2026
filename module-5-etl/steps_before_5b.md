# Lab 5B quick setup

1. Install the packages. In the terminal, run:

   ```powershell
   python -m pip install pandas sqlalchemy "psycopg[binary]" python-dotenv
   ```

2. In VS Code, right-click the `work` folder, choose **New File**, and name it `.env`.

3. Paste this line into `.env` and save:

   ```text
   DATABASE_URL=postgresql+psycopg://postgres:admin@localhost:5432/contact_center
   ```

4. Run the script:

   ```powershell
   cd C:\training\work
   python .\agent_daily_etl.py
   ```

If you use Notepad instead of VS Code, choose **Save as type: All Files** when you save, so the file is not saved as `.env.txt`.
