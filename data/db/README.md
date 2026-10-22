# Database setup (for the trainer, or for Option B in SETUP.md)

You only need this folder if you run your own PostgreSQL 16. If your trainer gave you a server name, skip it.

Run these from the course folder, in this order, as the `postgres` administrator. Replace the password when asked.

```powershell
psql -U postgres -c "CREATE DATABASE contact_centre"
psql -U postgres -d contact_centre -f data\db\schema.sql
psql -U postgres -d contact_centre -f data\db\load_csv.sql
psql -U postgres -d contact_centre -f data\db\practice.sql
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
psql -U postgres -c "CREATE DATABASE contact_centre"
pg_restore -U postgres -d contact_centre --no-owner data\db\contact_centre.dump
```

The `trainee` login can read `src` and `practice`, and can create tables and views in `reporting`.
