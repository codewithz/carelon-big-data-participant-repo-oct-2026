# Lab 10A: connect and load

Time: 20 minutes

Goal: connect Power BI Desktop to the PostgreSQL database on your VM, load your seven views, give them short names, and save the file.

You need: Module 9 finished, or see "If your views are not ready" below.

## Step 1. Check your version

1. Open Power BI Desktop. If a sign-in box appears, close it.
2. Choose Help on the ribbon, then About.

You should see a version number and a release month. Tell the trainer if it is more than a few months old: menus move between versions, and the steps in this module were written for recent ones.

## Step 2. Start a PostgreSQL connection

1. Choose Home, then Get data, then More.
2. In the search box, type `PostgreSQL`. Pick PostgreSQL database and click Connect.
3. Fill in:
   * Server: `localhost:5432`
   * Database: `contact_centre`
   * Data Connectivity mode: Import
4. Click OK.

## Step 3. Sign in

1. On the left of the box that opens, choose Database.
2. User name: `postgres`. Password: `admin`.
3. Click Connect.

If a box says Power BI could not connect using an encrypted connection and offers to connect without encryption, click OK. The database on your VM does not use encryption, and the data never leaves the VM. At work, ask whoever runs the database to turn it on instead.

If you see `password authentication failed`, check the user name and password. To type them again: File, then Options and settings, then Data source settings, pick the server, Clear Permissions, and start Step 2 again.

## Step 4. Pick your views

The Navigator lists every table and view you are allowed to read, written as `schema.name`.

1. Tick these seven, all starting with `reporting.`:
   * `reporting.dim_agent`
   * `reporting.dim_date`
   * `reporting.dim_queue`
   * `reporting.kpi_agent_daily`
   * `reporting.kpi_fax_daily`
   * `reporting.kpi_qa_daily`
   * `reporting.kpi_queue_daily`
2. Do not tick `reporting.interactions`, `reporting.qa_clean` or the Day 1 tables (`agent_daily`, `calls_clean`, `etl_watermark`). They are the 68,305 detail rows. The dashboard only needs the counts.
3. Click Transform Data (not Load). This opens Power Query.

> [!NOTE]
> Why not `interactions`? Power BI could do all the counting itself from the detail rows. But then the KPI rules would live inside this one file, and the next report would need them written again. Your views keep the rules in the database, where every tool shares them.

## Step 5. Tidy the names in Power Query

Power Query is Power BI's own small tidy-up step. On the left you see seven queries, named like `reporting kpi_queue_daily`.

1. Double-click `reporting kpi_queue_daily` in the Queries list and change the name to `kpi_queue_daily`. Press Enter.
2. Do the same for the other six, removing `reporting` and the space from the start of each name.

You should see seven queries named exactly like the views: `dim_agent`, `dim_date`, `dim_queue`, `kpi_agent_daily`, `kpi_fax_daily`, `kpi_qa_daily`, `kpi_queue_daily`.

> [!NOTE]
> Why it matters: the measures in Lab 10C refer to tables by name, such as `kpi_queue_daily[offered]`. With the short names, the same measures work whether you loaded `reporting`, `solution` or the CSV fallback.

Click `kpi_queue_daily` and look at the small icon at the left of each column header. `123` is a whole number and a calendar is a date. Power Query read these types from PostgreSQL, so there is nothing to fix.

## Step 6. Load and save

1. Click Close & Apply at the top left. Power BI loads the seven tables. It takes a few seconds.
2. Choose File, then Save as, and save it in your course folder's `work` folder as `contact-centre-kpis.pbix`.

## Step 7. Check the row counts

1. On the far left, click the Table view icon (a small grid).
2. In the Data pane on the right, click `kpi_queue_daily`.

You should see the rows in the middle, and at the bottom of the screen: `Table: kpi_queue_daily (150 rows)`.

Click through the others:

| Table | Rows |
|---|---|
| `dim_agent` | 40 |
| `dim_date` | 30 |
| `dim_queue` | 6 |
| `kpi_agent_daily` | 5,980 |
| `kpi_fax_daily` | 22 |
| `kpi_qa_daily` | 2,331 |
| `kpi_queue_daily` | 150 |

Go back to the Report view (the icon at the top of the far left bar).

## If your views are not ready

Use the finished copies. In Step 4, tick the seven views that start with `solution.` instead. In Step 5, remove `solution ` from the start of each name. Lab 10E works the same, because the `solution` views follow `src` by themselves. Everything else is the same.

## If you cannot connect at all

The same seven tables are in `module-10-powerbi/data/` as CSV files.

1. Choose Home, then Get data, then Text/CSV.
2. Pick `module-10-powerbi\data\dim_agent.csv` and click Load.
3. Repeat for the other six files.
4. Carry on from Step 6. The query names already match.

The CSV files hold 2 September to 1 October. They cannot show a new day, so Lab 10E will not change your dashboard.

## Check yourself

1. Why load the KPI views and not `interactions`?
2. Why rename the queries?
3. What does Import mode mean for new data?

<details>
<summary>Answers</summary>

1. The KPI rules then live in the database, shared by every tool, and Power BI only has 150 rows to handle instead of 68,305.
2. So the measures in the next labs work whatever the source: `reporting`, `solution` or CSV.
3. Power BI keeps its own copy. New data only appears after a Refresh.

</details>

## Done?

Next is [Lab 10B](lab-10b-relationships.md).
