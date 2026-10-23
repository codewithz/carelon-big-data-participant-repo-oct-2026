# Database setup

Every candidate runs this once on their own training VM. The `postgres` password on the VMs is `admin`.

## The quick way: one script

`setup_contact_centre.sql` creates the database, every table, the `trainee` login and all the data as INSERT statements. It takes a few seconds.

Open Command Prompt in the folder that holds the file and run (change `16` if your version is different). You are asked for the `postgres` password: `admin`.

```
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -f setup_contact_centre.sql
```

In PowerShell, put `&` and a space in front of the command. The last thing it prints is a small table with 51363 and 20, which means it worked. The script also creates a `trainee` login for classes that share one server. On your own VM you do not need it: you use `postgres`.

Prefer pgAdmin? Create an empty database called `contact_centre` (right-click Databases, Create, Database), open the Query Tool on it, use the Open File button to load `setup_contact_centre_pgadmin.sql`, and press F5. The file is about 19 MB, so pgAdmin may take a minute. The psql way is faster.

> [!NOTE]
> On Windows, `psql` and `pg_restore` are not on the PATH after installing PostgreSQL, so typing just `psql` gives "'psql' is not recognized". Use the full path as shown.

## The longer ways

These commands work in Command Prompt. In PowerShell, put `&` and a space at the start of each line. Run them from the course folder, in this order, as the `postgres` administrator. You are asked for the password you chose during installation. The commands assume PostgreSQL 16 in the default folder. If you installed a different version, change the `16` in the path.

```powershell
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -c "CREATE DATABASE contact_centre"
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d contact_centre -f data\db\schema.sql
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d contact_centre -f data\db\load_csv.sql
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d contact_centre -f data\db\practice.sql
```

What each file does:

| File | What it does |
|---|---|
| `schema.sql` | Creates the `src` and `reporting` schemas, the tables, and the `trainee` login (password `change-me`, change it before class) |
| `load_csv.sql` | Loads the CSV files in `data/` into the `src` tables. Run it from the course folder because the paths are relative |
| `practice.sql` | Creates the small `practice` schema (20 calls, 4 queues) used in Modules 2 to 5 |
| `contact_centre.dump` | Everything above in one file, for `pg_restore` |

To restore from the dump instead:

```powershell
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -c "CREATE DATABASE contact_centre"
"C:\Program Files\PostgreSQL\16\bin\pg_restore.exe" -U postgres -d contact_centre --no-owner data\db\contact_centre.dump
```

The `trainee` login can read `src` and `practice`, and can create tables and views in `reporting`.

## Restore from pgAdmin instead

1. In pgAdmin, right-click Databases, choose Create, then Database. Name it `contact_centre` and save.
2. Right-click `contact_centre` and choose Restore.
3. Set Format to Custom or tar. Click the folder icon and pick `data\db\contact_centre.dump`. If the file is not listed, change the file type filter to All Files.
4. Open the Data Options tab and switch on "No owner". Click Restore.
5. When it finishes, expand `contact_centre`, Schemas, and check that `src`, `reporting` and `practice` are there.
6. The `trainee` login is created by `schema.sql`, which the dump does not include. Create it once: open the Query Tool on `contact_centre` and run the `CREATE ROLE` and `GRANT` lines at the bottom of `schema.sql`, then `GRANT USAGE ON SCHEMA practice TO trainee; GRANT SELECT ON ALL TABLES IN SCHEMA practice TO trainee;`.

## Day 2

Day 2 needs three more scripts in this folder, all run by you on your own VM:

- `day2_setup.sql` (Lab 7A) removes the practice day from Demo 5C if it is still there and builds the finished Day 2 views in the `solution` schema. Your own work goes in `reporting`.
- `simulate_new_day.sql` (Lab 10E) adds a pretend 2 October so you can watch a refresh.
- `undo_new_day.sql` takes that day out again.
