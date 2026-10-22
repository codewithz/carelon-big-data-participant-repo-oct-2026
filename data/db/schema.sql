-- Day 1 training database. Synthetic data only.
-- Run as a superuser while connected to the contact_centre database.
-- Use `psql -U postgres -d contact_centre -f schema.sql`.

DROP SCHEMA IF EXISTS src CASCADE;
DROP SCHEMA IF EXISTS reporting CASCADE;
CREATE SCHEMA src;
CREATE SCHEMA reporting;

CREATE TABLE src.queues (
    queue_id         int PRIMARY KEY,
    queue_name       text NOT NULL,
    channel          text NOT NULL CHECK (channel IN ('voice', 'chat', 'fax')),
    sl_threshold_sec int  NOT NULL
);

CREATE TABLE src.agents (
    agent_id   int PRIMARY KEY,
    agent_name text NOT NULL,
    team       text NOT NULL,
    site       text NOT NULL
);

-- No primary key on purpose: the extract contains duplicate rows, as many real exports do.
CREATE TABLE src.calls (
    call_id     bigint,
    customer_id int,
    queue_id    int,
    agent_id    int,
    arrived_at  timestamptz,
    answered_at timestamptz,
    ended_at    timestamptz,
    wait_sec    int,
    talk_sec    int,
    hold_sec    int,
    wrap_sec    int,
    outcome     text
);

-- Chat timestamps are Philippine local time stored WITHOUT a time zone, on purpose.
CREATE TABLE src.chats (
    chat_id           bigint PRIMARY KEY,
    customer_id       int,
    queue_id          int,
    agent_id          int,
    started_at_local  timestamp,
    accepted_at_local timestamp,
    ended_at_local    timestamp,
    handle_sec        int,
    outcome           text,
    transcript        jsonb
);

CREATE TABLE src.faxes (
    fax_id       bigint PRIMARY KEY,
    customer_id  int,
    queue_id     int,
    agent_id     int,
    received_at  timestamptz,
    processed_at timestamptz,
    pages        int,
    status       text
);

-- score_text is text such as '85%', on purpose.
CREATE TABLE src.qa_scores (
    qa_id          bigint PRIMARY KEY,
    channel        text,
    interaction_id bigint,
    agent_id       int,
    evaluated_at   timestamptz,
    score_text     text
);

-- Participant login: read-only on src, full rights on reporting.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'trainee') THEN
        CREATE ROLE trainee LOGIN PASSWORD 'change-me';
    END IF;
END $$;

GRANT USAGE ON SCHEMA src TO trainee;
GRANT SELECT ON ALL TABLES IN SCHEMA src TO trainee;
GRANT ALL ON SCHEMA reporting TO trainee;
