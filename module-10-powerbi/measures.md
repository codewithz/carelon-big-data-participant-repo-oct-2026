# Measures

Every measure used in Module 10. To add one: select the table named in the first column in the Data pane, choose Home, then New measure, paste the line into the formula bar and press Enter.

## Lab 10C: the queue KPIs

| Put in table | Measure | Format |
|---|---|---|
| `kpi_queue_daily` | `Offered = SUM(kpi_queue_daily[offered])` | Whole number |
| `kpi_queue_daily` | `Abandonment rate = DIVIDE(SUM(kpi_queue_daily[abandoned]), SUM(kpi_queue_daily[offered]))` | Percentage, 1 decimal |
| `kpi_queue_daily` | `AHT (sec) = DIVIDE(SUM(kpi_queue_daily[handle_sec_total]), SUM(kpi_queue_daily[answered]))` | Whole number, 0 decimals |
| `kpi_queue_daily` | `Service level = DIVIDE(SUM(kpi_queue_daily[answered_in_sl]), SUM(kpi_queue_daily[answered]) + SUM(kpi_queue_daily[abandoned_after_sl]))` | Percentage, 1 decimal |
| `kpi_fax_daily` | `Fax within target = DIVIDE(SUM(kpi_fax_daily[within_target]), SUM(kpi_fax_daily[processed]))` | Percentage, 1 decimal |

## Lab 10D: the agent table

| Put in table | Measure | Format |
|---|---|---|
| `kpi_agent_daily` | `Contacts handled = SUM(kpi_agent_daily[contacts_handled])` | Whole number |
| `kpi_agent_daily` | `Agent AHT (sec) = DIVIDE(SUM(kpi_agent_daily[handle_sec_total]), SUM(kpi_agent_daily[contacts_handled]))` | Whole number, 0 decimals |
| `kpi_qa_daily` | `QA score = DIVIDE(SUM(kpi_qa_daily[score_total]), SUM(kpi_qa_daily[scored]))` | Decimal, 1 decimal |

## Challenge 10F: the hour page

| Put in table | Measure | Format |
|---|---|---|
| `kpi_queue_hourly` | `Service level (hourly) = DIVIDE(SUM(kpi_queue_hourly[answered_in_sl]), SUM(kpi_queue_hourly[answered]) + SUM(kpi_queue_hourly[abandoned_after_sl]))` | Percentage, 1 decimal |

## Why every rate is `DIVIDE(SUM(...), SUM(...))`

`DIVIDE(a, b)` is `a / b`, except that it returns blank instead of an error when `b` is 0. A Billing filter on the fax card is the classic case: no faxes, nothing to divide by, an empty card instead of an error.

Each measure adds up the counts for whatever is on screen first, then divides once. That is the rule from Lab 9C. Never add a column that already holds a percentage and average it.

## Expected values with no filters (2 September to 1 October)

| Measure | Value |
|---|---|
| Offered | 65,570 |
| Abandonment rate | 6.7% |
| AHT (sec) | 427 |
| Service level | 76.7% |
| Fax within target | 77.9% |
| Contacts handled | 61,021 |
| Agent AHT (sec) | 427 |
| QA score | 77.1 |
