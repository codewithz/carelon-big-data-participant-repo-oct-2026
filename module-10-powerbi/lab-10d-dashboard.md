# Lab 10D: build the dashboard

Time: 40 minutes

Goal: build one page that answers a team leader's morning questions. How busy were we? Did we answer fast enough? Which queue is struggling? Which agents need a look?

You need: Lab 10C finished.

## What you are building

```text
+--------------------------------------------------------------------------+
| Contact centre KPIs                        [ date range ]  [ queue    v] |
| Definitions: appendix/kpi-definitions.md                                  |
+-----------+-------------+-----------+---------------+--------------------+
|  Offered  | Abandonment |    AHT    | Service level | Fax within target  |
|  65,570   |    6.7%     |    427    |     76.7%     |       77.9%        |
+-----------+-------------+-----------+---------------+--------------------+
| Service level by day           | Abandonment rate by queue               |
|   line, with an 80% target     |   bars, worst at the top                |
+--------------------------------+-----------------------------------------+
| Agents: name, team, contacts handled, AHT, QA score                      |
+--------------------------------------------------------------------------+
```

## Step 1. Three more measures

Add these the same way as in Lab 10C. The first two go in `kpi_agent_daily`, the third in `kpi_qa_daily`.

```text
Contacts handled = SUM(kpi_agent_daily[contacts_handled])
```

```text
Agent AHT (sec) = DIVIDE(SUM(kpi_agent_daily[handle_sec_total]), SUM(kpi_agent_daily[contacts_handled]))
```

```text
QA score = DIVIDE(SUM(kpi_qa_daily[score_total]), SUM(kpi_qa_daily[scored]))
```

Format: Contacts handled as a whole number with the thousands separator, Agent AHT (sec) as a whole number with 0 decimals, QA score as a decimal number with 1 decimal place.

> [!NOTE]
> Why a second AHT? `AHT (sec)` counts every answered contact in the queue. `Agent AHT (sec)` leaves out the 150 answered calls with no agent, because they belong to no one. The two are a fraction of a second apart for the month, but on a small filter they can differ, and that is correct.

## Step 2. Title and the warning

1. Choose Insert, then Text box. Type `Contact centre KPIs`, select the text and make it bigger (size 20 or so) and bold.
2. Add a second, smaller text box under it: `Definitions: appendix/kpi-definitions.md. Assumed industry defaults until the client confirms.`
3. Drag both to the top left.

The warning stays on the page on purpose. A dashboard looks official, and people will compare it with their own reports. The definitions are the first thing to check when two numbers disagree.

## Step 3. Two slicers

1. Click an empty part of the page. In Visualizations, click Slicer. Tick `date` in `dim_date`. You should see a slider with two date boxes. Drag it to the top right.
2. Click an empty part of the page again, click Slicer, and tick `queue_name` in `dim_queue`. Put it next to the date slicer.
3. With the queue slicer selected, open Format visual (the paintbrush) and find Slicer settings, then Style. Choose Dropdown.

## Step 4. Five cards

1. Click an empty part of the page. In Visualizations, click Card. Tick the `Offered` measure.
2. Repeat for Abandonment rate, AHT (sec), Service level and Fax within target, one card each.
3. Line the five cards up in a row under the title.

You should see 65,570, 6.7%, 427, 76.7% and 77.9%.

If the Offered card shows `66K` instead of 65,570, select it, open Format visual (the paintbrush), find Callout value, and set Display units to None.

> [!TIP]
> Copying is faster than starting again: select a finished card, press Ctrl+C then Ctrl+V, and swap the measure in the new copy's field well.

## Step 5. Service level by day, against target

1. Click an empty part of the page, then the Line chart visual.
2. Drag `date` from `dim_date` to the X-axis. Drag the `Service level` measure to the Y-axis.
3. With the chart selected, open the Analytics pane (the magnifying glass icon next to the paintbrush; in some versions it is called "Add further analyses"). Find Constant line (Y-axis constant line in some versions), click Add, and set the value to `0.8`.
4. Give the line a label if the pane offers one: `Target 80%`.

You should see a line that wanders between about 74% and 80%, under the target line almost every day.

> [!NOTE]
> The 80% target is a common industry choice (80 percent answered within the target time). The client's own target goes here once it is confirmed. 0.8 is how Power BI writes 80% for a measure formatted as a percentage.

## Step 6. Abandonment rate by queue

1. Click an empty part of the page, then the Clustered bar chart visual.
2. Drag `queue_name` from `dim_queue` to the Y-axis and the `Abandonment rate` measure to the X-axis.
3. Click the three dots (More options) on the chart, choose Sort axis, then Abandonment rate, then Sort descending.

You should see Eligibility at the top with 7.3%, then Billing 7.2%, Provider Line 7.0%, Claims 6.8% and Web Chat 5.6%. Back Office Fax has no bar: it has no calls or chats.

## Step 7. The agent table

1. Click an empty part of the page, then the Table visual.
2. Tick `agent_name` and `team` in `dim_agent`, then the measures `Contacts handled`, `Agent AHT (sec)` and `QA score`.
3. Click the `Agent AHT (sec)` column header in the table to sort by it. Click again to flip the order.
4. In the visual's field well (Columns), click the small arrow next to `Agent AHT (sec)`, choose Conditional formatting, then Background color. Leave the default colours and click OK.

You should see 40 agents and a Total row with 61,021 contacts handled, AHT 427 and QA score 77.1. The longer an agent's AHT, the stronger the background colour.

## Step 8. Try it like a team leader

1. In the queue slicer, pick Billing.
2. In the date slicer, type 1 October 2026 in both boxes, in the date format your laptop shows.

You should see the cards change to 566, 7.4%, 343 and 74.2%, and the fax card goes blank, because the Billing queue has no faxes. Sort the agent table by Agent AHT (sec) from low to high: Agent 03 is first with 267, as in Lab 9B.

3. Clear both slicers: hover over each one and click the eraser icon.

Press Ctrl+S.

## Check yourself

1. Why does the fax card go blank when Billing is picked?
2. The team leader says: "Service level is under 80% on almost every day." Which visual shows that, and what would you check before they act on it?
3. Why is `Agent AHT (sec)` a separate measure from `AHT (sec)`?

<details>
<summary>Answers</summary>

1. The queue filter flows into every KPI table. Billing has no faxes, so there is nothing to divide, and `DIVIDE` returns a blank instead of an error.
2. The line chart with the target line. Check the definition first: is 80% within 20 seconds the agreed target, and are short abandons left out the way the client counts them?
3. It leaves out answered calls with no agent, which cannot belong to anyone. Queue numbers include them.

</details>

## Done?

Next is [Lab 10E](lab-10e-refresh.md).
