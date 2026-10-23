# Module 8: transform in Python

Time: 60 minutes

Raw data is rarely ready to report on. Yesterday you met two problems that were left for today: chat times saved with no time zone, and quality scores saved as text like `85%`. Today you fix both, then put calls, chats and faxes into one table so the rest of the day only has one place to look.

> [!TIP]
> The prep kitchen. Ingredients arrive from three suppliers, each packed differently. Before service, someone unpacks them, washes them, cuts them the same way and puts them in labelled tubs. The cooks only ever reach for the tubs.

## What changes between raw and clean

| Problem | Where | Fix | Lab |
|---|---|---|---|
| Quality scores are text such as `85%` | `src.qa_scores` | Strip the `%`, turn the rest into a number | 8A |
| Chat times have no time zone | `src.chats` | Say they are Manila time | 8A |
| Repeated call rows | `src.calls` | Drop exact copies (as in Lab 3E) | 8B |
| Answered calls with no agent | `src.calls` | Keep them, but flag them (as in Lab 4D) | 8B |
| Three channels, three shapes | calls, chats, faxes | Rename to the same columns and stack them | 8B |

## The target: one row per contact

| Column | Voice | Chat | Fax |
|---|---|---|---|
| `channel` | `voice` | `chat` | `fax` |
| `source_id` | `call_id` | `chat_id` | `fax_id` |
| `arrived_at` | call arrived | chat started | fax received |
| `answered_at` | agent picked up | agent accepted | fax processed |
| `wait_sec` | seconds in the queue | seconds until accepted, or until the customer left | turnaround: received to processed |
| `handle_sec` | talk + hold + wrap | chat length after accepted | 0 |
| `outcome` | `answered` or `abandoned` | `answered` or `abandoned` | `processed` |
| `contact_date` | the day in Manila time | the day in Manila time | the day in Manila time |
| `is_valid` | False for an answered call with no agent | the same rule | always True |

Putting a fax turnaround in a column called `wait_sec` is a choice, not a law. It lets one view apply "within the target time" to every channel. The column table above is the agreement that makes it safe, and it lives with the code.

## Labs

| Lab | What you do | Time |
|---|---|---|
| [Lab 8A](lab-8a-fix-messy-columns.md) | Fix the QA scores and the chat times, on 6 rows first | 25 min |
| [Lab 8B](lab-8b-one-table.md) | Run the script that builds `reporting.interactions` from all three channels, then check it | 35 min |
| [Challenge 8C](challenge-8c-your-own-step.md) | Write a whole extract, transform, load and check yourself, then break it on purpose | 30 min, optional |

> [!NOTE]
> Lab 4D (flag columns and lookups) was moved from Day 1. If your group skipped it, do it at home: the script in Lab 8B uses both ideas, and the lab explains where.

Start with [Lab 8A](lab-8a-fix-messy-columns.md).
