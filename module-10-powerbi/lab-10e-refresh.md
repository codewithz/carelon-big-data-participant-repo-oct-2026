# Lab 10E: a new day arrives

Time: 10 minutes

Goal: run the whole flow once more, end to end. New data arrives, you rebuild your table, Power BI refreshes, and the dashboard grows by one day without you touching a single visual.

You need: Lab 10D finished and saved, with both slicers cleared.

## Step 1. Note where you are

Write down the Offered card: 65,570. Look at the last date on the line chart: 1 October.

## Step 2. Add 2 October

In real life the new day arrives overnight. On your VM you play the supplier:

1. In pgAdmin, open the Query Tool on `contact_centre`.
2. Click Open File, pick `data\db\simulate_new_day.sql` from the course folder, and press F5.

You should see `Query returned successfully`. If you see "The new day is already there", it was run before: carry on, the day is in place.

> [!TIP]
> The morning delivery from Module 5, again. The suppliers drop new boxes in the store room overnight. Nothing in the dining room changes until the kitchen does its prep.

## Step 3. Rebuild your table

In the terminal:

```powershell
python module-8-transform\build_interactions.py
```

You should see:

```text
2026-10-23 14:22:05,412 INFO Extracted 53302 calls, 15999 chats, 1838 faxes, 3076 QA scores
2026-10-23 14:22:05,540 INFO Transformed into 70877 interactions (154 flagged not valid)
2026-10-23 14:22:32,834 INFO Loaded reporting.interactions and reporting.qa_clean. Last day: 2026-10-02
```

You do not need to touch your views. They are saved queries, so they read the new rows the next time anyone asks. `dim_date` now runs to 2 October by itself, as Lab 9B promised.

## Step 4. Refresh Power BI

In Power BI Desktop, choose Home, then Refresh.

You should see:

* Offered changes to 68,033: the 65,570 from before plus 2,463 new calls and chats.
* The line chart ends on 2 October.
* The date slicer runs to 2 October.
* Abandonment rate stays at 6.7% and AHT at 427, and service level moves to 76.8%. The new day is a copy of 1 October, so it barely moves a 30 day total.

That is the whole flow: get data, transform, load, calculate, show, and run it again tomorrow.

If you used the CSV fallback in Lab 10A, nothing changes on your screen: CSV files are a snapshot.

## Step 5. What happens at work

In this lab you pressed Refresh yourself. In a team, the report is published to Power BI Service (the website) and refreshed on a schedule, for example every morning at 6. Two extra pieces make that work:

* A work or school Microsoft account, and a licence to share the report with others.
* An on-premises data gateway: a small program on a machine inside the company network that lets Power BI Service reach a database that is not on the internet, such as a PostgreSQL server in the office.

The trainer shows publishing in Module 11.

## Check yourself

1. Which steps did you run again, and which did you not touch?
2. Why did `dim_date` grow without any change to it?
3. What would be needed to make this refresh happen every morning without anyone pressing a button?

<details>
<summary>Answers</summary>

1. Ran again: the new-day script, the Python build and Refresh. Not touched: the views, the measures and every visual.
2. Its first and last day come from `interactions`, and a view runs its query fresh every time.
3. Publish the report to Power BI Service, set a scheduled refresh, run the Python build on a schedule before it (Day 1 Module 5), and install a gateway so the Service can reach the database.

</details>

## Done?

## Step 6. Back to 30 days (optional)

To run Lab 10E again, or before any challenge lab that expects 30 days, run `data\db\undo_new_day.sql` the same way as Step 2, then `build_interactions.py` again, then Refresh.

Save your file. Next is [Module 11](../module-11-fabric/README.md), a demo from the trainer.
