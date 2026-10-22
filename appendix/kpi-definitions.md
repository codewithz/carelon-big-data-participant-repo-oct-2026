# KPI definitions

These are the definitions used in the labs. They are common industry choices, picked so the course data has one clear answer. Your own centre may define some of them differently. Before copying any number into a real report, check these against your agreed definitions.

> [!WARNING]
> The same KPI name can mean different things in different teams. When two reports disagree, the first thing to compare is the definition, not the data.

| KPI | Formula | Used in |
| --- | --- | --- |
| Offered calls | All calls that reached a queue, minus short abandons | Lab 3E |
| Short abandon | A call abandoned in 5 seconds or less | Lab 3E |
| Abandonment rate | Abandoned calls divided by offered calls | Lab 3E |
| AHT (average handle time) | Average of talk time plus hold time plus after-call work, over answered calls | Labs 3E and 5B |
| Service level (SL) | Calls answered within the threshold, divided by calls answered plus calls abandoned after the threshold | Lab 3E |
| FCR (first contact resolution) | Answered contacts with no further answered contact from the same customer within 7 days, divided by all answered contacts. The Day 1 demo uses calls only | Demo 3F |
| Fax turnaround | Share of faxes processed within 4 business hours | Day 2 |

Service level thresholds are 20 seconds for voice queues and 60 seconds for chat.

In Lab 3E the SQL for these definitions is written out step by step.

## Worked example: Billing on 1 October 2026

| Step | Number |
| --- | --- |
| Calls that reached the queue | 573 |
| Short abandons (5 seconds or less) removed | 7 |
| Offered calls | 566 |
| Abandoned calls among those | 42 |
| Abandonment rate | 42 divided by 566, which is 7.4 percent |
| Average handle time | 343 seconds |
| Service level | 74.2 percent |

The numbers above match what the SQL in Lab 3E produces.
