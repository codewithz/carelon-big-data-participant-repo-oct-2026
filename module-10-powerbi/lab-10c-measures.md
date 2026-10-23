# Lab 10C: five measures

Time: 20 minutes

Goal: write the five KPI measures, format them, and check them against the numbers you know from Day 1 and Lab 9A.

You need: Lab 10B finished, and the Report view open.

## Step 1. Your first measure

1. In the Data pane on the right, click the name `kpi_queue_daily` (the table name itself, not a column).
2. Choose Home, then New measure. A formula bar opens above the page with `Measure = `.
3. Replace the whole line with:

   ```text
   Offered = SUM(kpi_queue_daily[offered])
   ```

4. Press Enter.

You should see `Offered` appear in the Data pane under `kpi_queue_daily`, with a small calculator icon.

> [!NOTE]
> What this does: the part before `=` is the name. `SUM(kpi_queue_daily[offered])` adds up the `offered` column, written as `table[column]`. A measure is not stored anywhere. It is worked out again every time it is shown, for exactly the rows that the page's filters let through.

## Step 2. The three rates

Click `kpi_queue_daily` again, then New measure, for each of these. Type each one exactly, or copy it from [measures.md](measures.md).

```text
Abandonment rate = DIVIDE(SUM(kpi_queue_daily[abandoned]), SUM(kpi_queue_daily[offered]))
```

```text
AHT (sec) = DIVIDE(SUM(kpi_queue_daily[handle_sec_total]), SUM(kpi_queue_daily[answered]))
```

```text
Service level = DIVIDE(SUM(kpi_queue_daily[answered_in_sl]), SUM(kpi_queue_daily[answered]) + SUM(kpi_queue_daily[abandoned_after_sl]))
```

Then click `kpi_fax_daily` in the Data pane, New measure:

```text
Fax within target = DIVIDE(SUM(kpi_fax_daily[within_target]), SUM(kpi_fax_daily[processed]))
```

> [!NOTE]
> Every rate is one total divided by another total: add up first, divide once. That is the rule you proved in Lab 9C. `DIVIDE` is the same as `/`, except it shows a blank instead of an error when there is nothing to divide by.

If a measure is underlined in red, hover over the red line to read why. The usual causes are a missing bracket or a table name that still has `reporting` at the front (go back to Lab 10A step 5).

## Step 3. Format them

Click each measure in the Data pane, then use the Measure tools tab on the ribbon:

| Measure | Format | Decimal places |
|---|---|---|
| Offered | Whole number, with the thousands separator (the `,` button) on | 0 |
| Abandonment rate | Percentage | 1 |
| AHT (sec) | Whole number | 0 |
| Service level | Percentage | 1 |
| Fax within target | Percentage | 1 |

## Step 4. Check against Day 1

1. Click on an empty part of the page. In the Visualizations pane, click the Table visual (a small grid icon).
2. From the Data pane, tick `queue_name` under `dim_queue`, then tick the four measures under `kpi_queue_daily`: Offered, Abandonment rate, AHT (sec), Service level.
3. Make the visual bigger by dragging its corner.

You should see the whole month, one row per queue, and a Total row:

```text
queue_name      Offered   Abandonment rate   AHT (sec)   Service level
Billing          15,047               7.2%         351           73.4%
Claims           15,037               6.8%         353           73.3%
Eligibility      10,951               7.3%         352           72.8%
Provider Line     9,098               7.0%         354           72.3%
Web Chat         15,437               5.6%         665           88.5%
Total            65,570               6.7%         427           76.7%
```

Look at the Total row for AHT: 427, not 415. Power BI added the totals and divided once, so it gave the true AHT from Lab 9C, not the average of the five queues.

Now narrow it to one day:

1. Open the Filters pane (on the right, next to Visualizations; click Filters if it is collapsed).
2. Drag `date` from `dim_date` into "Filters on this page".
3. Choose Basic filtering if asked, scroll to the bottom of the list and tick only 1 October 2026.

You should see:

```text
queue_name      Offered   Abandonment rate   AHT (sec)   Service level
Billing             566               7.4%         343           74.2%
Claims              583               7.2%         349           75.7%
Eligibility         410               7.8%         343           72.6%
Provider Line       348               6.9%         362           70.7%
Web Chat            556               5.8%         659           90.7%
```

The same numbers as Lab 3E and Lab 9A. Three tools, one answer.

## Step 5. Clean up

1. Remove the date filter: hover over it in the Filters pane and click the eraser or the X.
2. Click the table visual and press Delete. You will build the real page in the next lab.
3. Press Ctrl+S.

## Check yourself

1. Why is the AHT Total 427 and not the average of the five rows?
2. When does `DIVIDE` show a blank?
3. A colleague writes `Abandonment rate = AVERAGE(kpi_queue_daily[abandon_pct])` on a column of daily percentages. What is wrong?

<details>
<summary>Answers</summary>

1. The measure adds all handle seconds and all answered contacts for whatever is on the row, then divides once. On the Total row that is the whole month.
2. When the bottom number is 0 or blank, for example the fax measure when only a voice queue is picked.
3. It averages daily percentages, so a quiet day counts as much as a busy one. It is the trap from Lab 9C.

</details>

## Done?

Next is [Lab 10D](lab-10d-dashboard.md).
