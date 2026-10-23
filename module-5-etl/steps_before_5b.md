In a terminal, run: python -m pip install pandas sqlalchemy "psycopg[binary]" python-dotenv
In VS Code, right-click the work folder, choose New File, and name it .env.
Paste this single line into it and save:
DATABASE_URL=postgresql+psycopg://postgres:admin@localhost:5432/contact_center
In the terminal, run: cd C:\training\work and then python .\agent_daily_etl.py