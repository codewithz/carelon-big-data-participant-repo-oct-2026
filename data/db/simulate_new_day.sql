-- Pretend a new day arrived: 1 October copied forward to 2 October.
-- Used in Day 1 Demo 5C (calls only matter there) and Day 2 Lab 10E (calls, chats and faxes).
-- Run it in pgAdmin on your own VM (Open File, then F5).
-- If 2 October is already there, it stops with an error and changes nothing.
BEGIN;
SET TIME ZONE 'Asia/Manila';

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM src.calls WHERE call_id >= 1000000) THEN
        RAISE EXCEPTION 'The new day is already there. Run undo_new_day.sql first if you want to start again.';
    END IF;
END $$;

INSERT INTO src.calls
SELECT call_id + 1000000, customer_id, queue_id, agent_id,
       arrived_at  + interval '1 day',
       answered_at + interval '1 day',
       ended_at    + interval '1 day',
       wait_sec, talk_sec, hold_sec, wrap_sec, outcome
FROM src.calls
WHERE arrived_at >= '2026-10-01 00:00+08' AND arrived_at < '2026-10-02 00:00+08';

INSERT INTO src.chats
SELECT chat_id + 1000000, customer_id, queue_id, agent_id,
       started_at_local  + interval '1 day',
       accepted_at_local + interval '1 day',
       ended_at_local    + interval '1 day',
       handle_sec, outcome, transcript
FROM src.chats
WHERE started_at_local >= '2026-10-01' AND started_at_local < '2026-10-02';

INSERT INTO src.faxes
SELECT fax_id + 1000000, customer_id, queue_id, agent_id,
       received_at  + interval '1 day',
       processed_at + interval '1 day',
       pages, status
FROM src.faxes
WHERE received_at >= '2026-10-01 00:00+08' AND received_at < '2026-10-02 00:00+08';

COMMIT;

-- To undo it, run undo_new_day.sql.
