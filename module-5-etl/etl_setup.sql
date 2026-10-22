-- Run once, as the trainee login, before the first ETL run.
CREATE TABLE IF NOT EXISTS reporting.agent_daily (
    agent_id         int  NOT NULL,
    summary_date     date NOT NULL,
    calls_handled    int  NOT NULL,
    aht_sec          int  NOT NULL,
    longest_call_sec int  NOT NULL,
    loaded_at        timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (agent_id, summary_date)
);

CREATE TABLE IF NOT EXISTS reporting.etl_watermark (
    job_name         text PRIMARY KEY,
    last_loaded_date date NOT NULL
);
