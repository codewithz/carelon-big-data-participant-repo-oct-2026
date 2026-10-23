# Contact centre data: Days 1 and 2

Welcome. This course takes you from "I have never written code" to running a small data pipeline yourself. You do not need any experience with Python or SQL. Every step is written out, every step says what you should see, and the data starts very small so you can check your own answers by eye.

## What you will be able to do by the end of the day

* Open a terminal, move between folders and run a program
* Write and run small Python programs
* Ask a database questions with SQL and work out call centre numbers (abandonment, handling time, service level)
* Find and fix common problems in a data file
* Run a data pipeline twice and explain why the result stays the same

## The day

| Time | What | Where |
| --- | --- | --- |
| 09:00 | Welcome and your tools | [Module 0](module-0-tools/README.md) |
| 09:40 | Big data and how reporting works | [Module 1](module-1-landscape/README.md) |
| 10:15 | Break | |
| 10:30 | Python from zero | [Module 2](module-2-python/README.md) |
| 12:00 | Lunch | |
| 12:45 | SQL from zero, part 1 | [Module 3](module-3-sql/README.md) |
| 14:00 | Break | |
| 14:15 | SQL from zero, part 2: the call centre numbers | [Module 3](module-3-sql/README.md) |
| 15:15 | Cleaning a data file | [Module 4](module-4-cleaning/README.md) |
| 16:00 | Break | |
| 16:10 | Your first data pipeline | [Module 5](module-5-etl/README.md) |
| 16:45 | When to use a special database | [Module 6](module-6-jsonb/README.md) |
| 16:55 | Wrap-up | |

## Day 2: from data to dashboard

By the end of Day 2 you can:

* Fix columns that are stored the wrong way (scores as text, times with no time zone)
* Combine calls, chats and faxes into one table with a Python script
* Write KPI rules once, as SQL views that hold counts
* Build a Power BI dashboard on those views and refresh it when a new day arrives
* Explain how the same flow looks in Microsoft Fabric

| Time | What | Where |
| --- | --- | --- |
| 09:00 | From data to dashboard, and get your database ready | [Module 7](module-7-reporting-layer/README.md) |
| 09:20 | Transform in Python | [Module 8](module-8-transform/README.md) |
| 10:20 | Break | |
| 10:35 | KPIs in SQL | [Module 9](module-9-kpi-views/README.md) |
| 11:50 | Lunch | |
| 12:35 | Power BI: connect, link, measure | [Module 10](module-10-powerbi/README.md) |
| 13:25 | Power BI: build the dashboard | [Module 10](module-10-powerbi/README.md) |
| 14:05 | Break | |
| 14:20 | Power BI: a new day arrives | [Module 10](module-10-powerbi/README.md) |
| 14:30 | The same flow in Microsoft Fabric (trainer demo) | [Module 11](module-11-fabric/README.md) |
| 14:55 | Wrap-up | |

The day ends at 16:00. The time after the wrap-up is kept free on purpose: beginners' labs always take longer than planned, and the trainer will use it during the day.

Before Day 2, follow the [Before Day 2](SETUP.md#before-day-2) section of SETUP.md.

## How to use this course

Each module folder has a README that explains the ideas in plain words with everyday comparisons, followed by labs. A lab is a short hands-on task. Do the labs in order.

Every lab follows the same layout:

1. A goal in one sentence
2. Numbered steps, each with the exact text to type
3. What you should see, so you can check your result after every step
4. What to do if your result is different
5. A few questions to check yourself

If you fall behind, every lab folder has a `solutions` file. Copy it, run it, and rejoin the class. Falling behind on day one is normal.

## Before the day

Follow [SETUP.md](SETUP.md). It ends with one command that checks your VM and tells you what, if anything, is missing.

## What is in this folder

```text
README.md             this page
SETUP.md              get your VM ready
module-0-tools/       terminal, folders and files
module-1-landscape/   how reporting data flows
module-2-python/      Python labs
module-3-sql/         SQL labs
module-4-cleaning/    cleaning a data file
module-5-etl/         a data pipeline
module-6-jsonb/       NoSQL in one demo
module-7-reporting-layer/  Day 2: the plan for the day, Day 2 setup
module-8-transform/   Day 2: clean and combine in Python
module-9-kpi-views/   Day 2: KPI rules as SQL views
module-10-powerbi/    Day 2: the dashboard
module-11-fabric/     Day 2: trainer demo notes
data/                 all the data files and database setup
work/                 your own files go here
appendix/             glossary, cheat sheets, troubleshooting
check_setup.py        checks your VM (Day 1)
check_day2.py         checks your VM is ready (Day 2)
```

> [!NOTE]
> All data in this course is invented. No real customer, member or agent appears in it.
