# Data guide

All data is invented. No real customers or calls.

## Folders

| Path | What it is |
|---|---|
| `data/practice/` | Small files for the first labs. 20 calls you can check by eye, and a 12-row messy file |
| `data/*.csv` | The full 30-day contact centre data set, 2 September to 1 October 2026 |
| `data/db/` | SQL files for the trainer that load everything into PostgreSQL |

## Practice files

| File | Rows | Used in |
|---|---|---|
| `calls_sample.csv` | 20 | Labs 2D, 3A to 3E, 5A |
| `queues_sample.csv` | 4 | Labs 3D and 3E |
| `messy_calls_sample.csv` | 12 | Labs 4A and 4B |

## Full data files

| File | Rows | What one row is |
|---|---|---|
| `calls.csv` | 51,363 | One phone call. 255 are repeated rows |
| `calls_2026-10-01.csv` | 1,939 | The calls of one day |
| `chats.csv` | 15,443 | One web chat |
| `chats_2026-10-01.csv` | 556 | The chats of one day |
| `faxes.csv` | 1,754 | One fax |
| `qa_scores.csv` | 3,076 | One quality score for a call |
| `agents.csv` | 40 | One agent |
| `queues.csv` | 6 | One queue and its service level target |

## Columns in calls

| Column | Meaning |
|---|---|
| `call_id` | Call number |
| `customer_id` | Customer number (random in this data) |
| `queue_id` | Which queue. 1 Billing, 2 Claims, 3 Eligibility, 4 Provider Line |
| `agent_id` | Agent who answered. Empty for abandoned calls |
| `arrived_at` | When the call entered the queue |
| `answered_at` | When an agent picked up. Empty for abandoned calls |
| `ended_at` | When the call ended |
| `wait_sec` | Seconds waiting before answer or hang up |
| `talk_sec` | Seconds talking |
| `hold_sec` | Seconds on hold |
| `wrap_sec` | Seconds of after-call work |
| `outcome` | `answered` or `abandoned` |

## Known problems on purpose

| Problem | Where | Taught in |
|---|---|---|
| Repeated rows | `calls.csv` has 255, the one-day file has 7 | Labs 3E and 4C |
| Answered calls with no agent | 4 in the one-day file | Lab 4C |
| Chat times without a time zone | `chats.csv` | Day 2 |
| Quality scores stored as text like `85%` | `qa_scores.csv` | Day 2 |
