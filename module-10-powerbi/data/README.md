# Power BI fallback files

These seven CSV files are copies of the finished views in `solution`, for 2 September to 1 October 2026. Use them only if Power BI cannot connect to PostgreSQL (Lab 10A, "If you cannot connect at all").

| File | Rows | One row is |
|---|---|---|
| `kpi_queue_daily.csv` | 150 | One queue on one day (voice and chat) |
| `kpi_agent_daily.csv` | 5,980 | One agent in one queue on one day |
| `kpi_fax_daily.csv` | 22 | The fax queue on one day |
| `kpi_qa_daily.csv` | 2,331 | One agent's quality scores in one queue on one day |
| `dim_date.csv` | 30 | One day |
| `dim_queue.csv` | 6 | One queue |
| `dim_agent.csv` | 40 | One agent |

The files are a snapshot. They do not change when new data arrives, so Lab 10E does nothing for anyone using them.
