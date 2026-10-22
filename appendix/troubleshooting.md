# Troubleshooting

Find the message you see in the first column. If the fix does not work, put your hand up.

| What you see | What it means | What to do |
|---|---|---|
| Typing `python` opens the Microsoft Store | Windows is redirecting the command | Open Settings, then Apps, then Advanced app settings, then App execution aliases. Switch off `python.exe` and `python3.exe` |
| `running scripts is disabled on this system` when activating the environment | PowerShell blocks scripts by default | Run `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`, then try again |
| `'psql' is not recognized` | Windows cannot find PostgreSQL's tools | You do not need psql in this course. Use pgAdmin |
| `password authentication failed for user "trainee"` | The password is wrong | Check `.env`. No spaces around the `=` and no quotes around the password |
| `connection refused` or `could not connect to server` | PostgreSQL is not running, or the port is different | Ask the trainer |
| `ModuleNotFoundError: No module named 'pandas'` | The environment is off | Check your prompt starts with `(.venv)`. If not, run `.venv\Scripts\Activate.ps1` |
| `FileNotFoundError` for a CSV file | The terminal is in the wrong folder | Check the prompt ends with the course folder name. Use `cd` to go there |
| `KeyError` followed by a column name | The column name is spelled differently | Print `calls.columns` and compare, including capital letters |
| `IndentationError` | The spaces at the start of a line do not match | Make every line inside a block start with the same number of spaces |
| `SyntaxError` | Python cannot read the line | Look at the line shown and the one above it. Missing brackets and quotes are the usual cause |
| A SQL query returns no rows | The date or text filter does not match | Check the date is `'2026-10-01'` and queue names match exactly, including capital letters |
| `permission denied for table` | Your login can only read the `src` and `practice` tables | Create tables only in the `reporting` schema |
| `relation "reporting.calls_clean" does not exist` | You have not done Step 8 of Lab 3E | Run the `CREATE VIEW` step again |
| The query window shows times 8 hours off | Your session is in UTC | Run `SET TIME ZONE 'Asia/Manila';` at the start of your session |
| pgAdmin runs every query in the editor | Nothing was selected | Select only the query you want, then press F5 |
| `python check_setup.py` says MISSING | A file, package or setting is missing | Read the hint printed next to the word MISSING |

## If everything fails

Tell your trainer. Every lab has the expected output next to each step, so the trainer can compare your screen against it.
