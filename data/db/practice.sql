-- Practice tables for Module 3. 20 calls, 4 queues. Small enough to check answers by eye.
-- Run as an administrator (the same login that ran schema.sql).
DROP SCHEMA IF EXISTS practice CASCADE;
CREATE SCHEMA practice;

CREATE TABLE practice.queues (
    queue_id         int PRIMARY KEY,
    queue_name       text NOT NULL,
    sl_threshold_sec int  NOT NULL
);

CREATE TABLE practice.calls (
    call_id    int PRIMARY KEY,
    queue_id   int REFERENCES practice.queues (queue_id),
    arrived_at timestamp,
    wait_sec   int,
    talk_sec   int,
    hold_sec   int,
    wrap_sec   int,
    outcome    text
);

INSERT INTO practice.queues VALUES
    (1, 'Billing', 20),
    (2, 'Claims', 20),
    (3, 'Eligibility', 20),
    (4, 'Provider Line', 20);

INSERT INTO practice.calls VALUES
    (1, 1, '2026-10-01 07:05:10', 5, 240, 0, 30, 'answered'),
    (2, 1, '2026-10-01 07:12:44', 12, 310, 20, 45, 'answered'),
    (3, 2, '2026-10-01 07:20:03', 30, 420, 60, 60, 'answered'),
    (4, 1, '2026-10-01 07:31:18', 3, 0, 0, 0, 'abandoned'),
    (5, 3, '2026-10-01 07:45:55', 8, 180, 0, 20, 'answered'),
    (6, 2, '2026-10-01 08:02:09', 45, 0, 0, 0, 'abandoned'),
    (7, 1, '2026-10-01 08:10:30', 18, 275, 15, 40, 'answered'),
    (8, 4, '2026-10-01 08:22:41', 22, 350, 30, 50, 'answered'),
    (9, 2, '2026-10-01 08:40:12', 10, 200, 0, 25, 'answered'),
    (10, 1, '2026-10-01 08:55:00', 25, 500, 90, 70, 'answered'),
    (11, 3, '2026-10-01 09:03:27', 15, 260, 0, 35, 'answered'),
    (12, 1, '2026-10-01 09:15:48', 60, 0, 0, 0, 'abandoned'),
    (13, 2, '2026-10-01 09:30:19', 6, 330, 45, 55, 'answered'),
    (14, 1, '2026-10-01 09:44:02', 9, 290, 0, 30, 'answered'),
    (15, 3, '2026-10-01 10:05:36', 35, 410, 70, 65, 'answered'),
    (16, 2, '2026-10-01 10:18:50', 14, 225, 0, 20, 'answered'),
    (17, 1, '2026-10-01 10:33:21', 20, 310, 25, 45, 'answered'),
    (18, 4, '2026-10-01 10:47:15', 4, 0, 0, 0, 'abandoned'),
    (19, 2, '2026-10-01 11:02:58', 28, 380, 40, 50, 'answered'),
    (20, 1, '2026-10-01 11:20:33', 7, 265, 0, 35, 'answered');

GRANT USAGE ON SCHEMA practice TO trainee;
GRANT SELECT ON ALL TABLES IN SCHEMA practice TO trainee;
