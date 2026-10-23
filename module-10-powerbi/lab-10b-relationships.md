# Lab 10B: link the tables

Time: 10 minutes

Goal: draw the lines between the KPI tables and the lookup lists, so that a click on "Billing" or "1 October" filters every number on the page.

You need: Lab 10A finished.

## Step 1. Open the model

Click the Model view icon on the far left (three boxes joined by lines).

You should see seven boxes. Power BI may already have drawn some lines: it links columns that have the same name, such as `queue_id` and `agent_id`, when one side is a lookup list. It cannot guess that `contact_date` belongs with `date`, so you draw those.

> [!TIP]
> Arrange the boxes like a star before you start: the four `kpi_` tables in the middle, `dim_date` on top, `dim_queue` on the left, `dim_agent` on the right. Drag a box by its title. It makes the lines much easier to read.

## Step 2. Link the dates

For each of the four KPI tables:

1. Drag `contact_date` from the KPI table and drop it on `date` in `dim_date`.
2. If a box opens, check it says Many to one (*:1) and Single for the cross-filter direction, then click Save. Some versions draw the line without asking.

Do this for `kpi_queue_daily`, `kpi_agent_daily`, `kpi_fax_daily` and `kpi_qa_daily`.

## Step 3. Check every line

Choose Home, then Manage relationships. You should see these ten, all active, all many to one:

| From (many) | To (one) |
|---|---|
| `kpi_queue_daily[contact_date]` | `dim_date[date]` |
| `kpi_queue_daily[queue_id]` | `dim_queue[queue_id]` |
| `kpi_agent_daily[contact_date]` | `dim_date[date]` |
| `kpi_agent_daily[queue_id]` | `dim_queue[queue_id]` |
| `kpi_agent_daily[agent_id]` | `dim_agent[agent_id]` |
| `kpi_fax_daily[contact_date]` | `dim_date[date]` |
| `kpi_fax_daily[queue_id]` | `dim_queue[queue_id]` |
| `kpi_qa_daily[contact_date]` | `dim_date[date]` |
| `kpi_qa_daily[queue_id]` | `dim_queue[queue_id]` |
| `kpi_qa_daily[agent_id]` | `dim_agent[agent_id]` |

If one is missing, click New relationship (or drag the columns in the Model view as in Step 2). If there is a line between two `kpi_` tables, delete it: KPI tables only ever link to lookup lists.

> [!NOTE]
> What this does: each line is a `JOIN` that Power BI keeps ready. "Many to one" means many rows in the KPI table point to one row in the lookup list: 30 Billing rows in `kpi_queue_daily`, one Billing row in `dim_queue`. "Single" means filters flow one way, from the lookup list into the counts. Pick Billing in `dim_queue`, and every KPI table narrows to Billing.

## Step 4. Tell Power BI which table is the calendar

1. In the Data pane, click `dim_date`.
2. On the ribbon, choose Table tools, then Mark as date table.
3. Pick the `date` column and click OK (or Save).

> [!NOTE]
> Why: without this, Power BI adds its own hidden calendar to every date column and shows dates as a Year, Quarter, Month, Day tree in charts. Marking `dim_date` stops that, so the dates you see in charts are the dates in your table.

## Step 5. Save

Press Ctrl+S.

## Check yourself

1. Why does `dim_date` link to all four KPI tables?
2. Which way do filters flow?
3. Why did Power BI not draw the date lines itself?

<details>
<summary>Answers</summary>

1. So one date filter narrows every number on the page at once.
2. From the lookup lists into the KPI tables.
3. The column names differ: `contact_date` in the KPI tables, `date` in `dim_date`.

</details>

## Done?

Next is [Lab 10C](lab-10c-measures.md).
