# Challenge 10F: a page for staffing

Time: 30 minutes. A challenge: fewer instructions, more thinking. Do it after Lab 10E if you have time, or at home.

Goal: add a second page to your dashboard that shows service level by hour and queue, so a team leader can see at a glance when to add staff. This time you decide the steps.

You need: Lab 10E finished, and Challenge 9D finished (it made `reporting.kpi_queue_hourly`). If you skipped 9D, run `module-9-kpi-views/solutions/challenge-9d-hourly.sql` in pgAdmin first.

## What the page shows

```text
+----------------------------------------------------------------+
| Service level by hour                     [ channel: voice  v] |
+----------------------------------------------------------------+
| hour | Billing | Claims | Eligibility | Provider Line | Total   |
|   7  |  94.3%  |  ...   |    ...      |     ...       |  94.3%  |
|  ... |         |        |             |               |         |
|  11  |  66.4%  |  ...   |    ...      |     ...       |  65.2%  |   <- red
|  ... |         |        |             |               |         |
+----------------------------------------------------------------+
```

A grid with hours down the side, queues across the top and the service level in each box, coloured from red (bad) to green (good).

## Step 1. Plan it

Write the steps on paper before you open Power BI. Use what you did in Labs 10A to 10D. There are five.

<details>
<summary>Compare with this plan</summary>

1. Load `reporting.kpi_queue_hourly` and rename the query `kpi_queue_hourly` (Lab 10A).
2. Link it to `dim_queue` and `dim_date` (Lab 10B).
3. Write a service level measure for the new table (Lab 10C).
4. Add a new page, a Matrix visual and a slicer (Lab 10D).
5. Check the numbers against Challenge 9D.

</details>

## Step 2. Load and link

Use Home, Get data (or Recent sources) to add the one new view. Then make sure it has two relationships, to `dim_queue[queue_id]` and to `dim_date[date]`.

<details>
<summary>Hint</summary>

In the Navigator tick only `reporting.kpi_queue_hourly`, choose Transform Data, rename the query, then Close & Apply. Power BI keeps the seven tables you already have. The date line needs dragging by hand, as in Lab 10B.

</details>

## Step 3. A measure for the new table

Write `Service level (hourly)` in the `kpi_queue_hourly` table. It is the Lab 10C service level measure, pointed at the new table. Format it as a percentage with 1 decimal.

<details>
<summary>Why not reuse the measure from Lab 10C?</summary>

`Service level` adds up columns of `kpi_queue_daily`. That table has no hours, so it cannot be split by hour. A measure belongs to the table whose counts it adds up.

</details>

## Step 4. Build the page

1. Add a new page with the `+` at the bottom of the screen. Rename it `By hour`.
2. Add a Matrix visual: `hour` from `kpi_queue_hourly` on Rows, `queue_name` from `dim_queue` on Columns, your new measure on Values.
3. Add a slicer on `channel` from `dim_queue`, and pick `voice`.
4. Colour the boxes: in the Values well, use the arrow next to the measure, Conditional formatting, Background color. Choose a colour scale from red for the lowest to green for the highest.

## Step 5. Check it

With `voice` picked, you should see:

| Check | Expected |
|---|---|
| Rows | 14 hours, 7 to 20 |
| Billing at 11 | 66.4% |
| Billing at 7 | 94.3% |
| Total column at 11 | 65.2%, the worst hour in Challenge 9D |
| Total column at 16 | 67.4% |
| Grand total, bottom right | 73.0% |

Then pick `chat` instead: Web Chat is between 86.9% and 90.0% in every hour. Chat has a 60 second target and few peaks.

If the numbers on this page do not change when you move the date slicer on page 1, that is expected: slicers work on their own page unless you sync them (View, Sync slicers). Try syncing the date slicer to both pages.

## Check yourself

1. Why does the Total column at 11:00 show 65.2% and not the average of the four queues in that row?
2. A team leader asks: "Why is the hour page's grand total 73.0% but page 1 shows 76.7%?" What is the answer?
3. What would you need to change in the database if the team wanted half hours instead of hours?

<details>
<summary>Answers</summary>

1. The measure adds up the counts of all four queues in that hour, then divides once. Big queues weigh more, as they should.
2. The hour page is filtered to voice. Page 1 includes Web Chat, which has a much higher service level. Same rule, different set of contacts.
3. One view: the half hour instead of the hour in `kpi_queue_hourly`, for example `date_trunc` on 30 minute steps. The measure and the page would work as they are.

</details>
