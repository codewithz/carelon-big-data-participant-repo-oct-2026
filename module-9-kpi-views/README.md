# Module 9: KPIs in SQL

Time: 75 minutes

You now have one clean table, `reporting.interactions`. In this module you write the KPI rules down once, as SQL views, so that Power BI, Excel or anyone with a query tool gets the same answer.

> [!TIP]
> The restaurant menu. It says exactly what goes into each dish. Every cook follows it, so the dish tastes the same whoever is on shift. A view is the menu for a number: anyone who asks for "abandonment" gets the same recipe.

## The rule from Module 7

**The views count. Power BI divides.**

Every KPI view holds counts and totals, never a percentage or an average. Power BI divides at the last moment, for exactly the days and queues on screen.

| KPI | The view stores | Power BI works out |
|---|---|---|
| Abandonment rate | `abandoned`, `offered` | abandoned ÷ offered |
| AHT | `handle_sec_total`, `answered` | handle seconds ÷ answered |
| Service level | `answered_in_sl`, `answered`, `abandoned_after_sl` | answered in time ÷ (answered + abandoned after the target) |
| Fax within target | `within_target`, `processed` | within target ÷ processed |
| QA score | `score_total`, `scored` | total score ÷ scores |

The rules are the same as Lab 3E. They are listed in the [KPI definitions](../appendix/kpi-definitions.md).

## The views you will build

| View | One row is | Lab |
|---|---|---|
| `reporting.kpi_queue_daily` | One queue on one day (voice and chat) | 9A |
| `reporting.dim_queue` | One queue | 9B |
| `reporting.dim_agent` | One agent | 9B |
| `reporting.dim_date` | One day | 9B |
| `reporting.kpi_agent_daily` | One agent in one queue on one day | 9B |
| `reporting.kpi_fax_daily` | The fax queue on one day | 9C |
| `reporting.kpi_qa_daily` | One agent's quality scores in one queue on one day | 9C |

## Labs

| Lab | What you do | Time |
|---|---|---|
| [Lab 9A](lab-9a-queue-kpi-view.md) | Count Billing on 1 October by hand in SQL, then save the counts as a view for every queue and day | 30 min |
| [Lab 9B](lab-9b-lookup-views.md) | Build the lookup lists and the agent view | 20 min |
| [Lab 9C](lab-9c-check-the-numbers.md) | Prove why percentages must not be averaged, add fax and QA, compare everything with the finished copies | 25 min |
| [Challenge 9D](challenge-9d-hourly-view.md) | Build an hourly view, prove it adds up to the daily one, find the worst hours | 30 min, optional |

All the SQL is in `solutions/kpi_views.sql` if you need to catch up. Open it in pgAdmin and press F5, and every view in this module is created at once in `reporting`. Every view you create today starts with `reporting.`, so it sits next to the table it reads.

Start with [Lab 9A](lab-9a-queue-kpi-view.md).
