-- Removes the pretend day added by simulate_new_day.sql and empties the Day 1 ETL tables.
-- After this, run the Day 1 ETL again to refill reporting.agent_daily.
-- Your Day 2 table reporting.interactions still holds 2 October until you run
-- module-8-transform\build_interactions.py again.
DELETE FROM src.calls WHERE call_id >= 1000000;
DELETE FROM src.chats WHERE chat_id >= 1000000;
DELETE FROM src.faxes WHERE fax_id >= 1000000;
DELETE FROM reporting.agent_daily;
DELETE FROM reporting.etl_watermark;
