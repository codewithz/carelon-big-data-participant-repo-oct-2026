-- Loads the CSV files in data/ into the tables made by data/schema.sql.
-- Run from the main course folder:
--   psql -U postgres -d contact_centre -f data/db/schema.sql
--   psql -U postgres -d contact_centre -f data/db/load_csv.sql
SET TIME ZONE 'Asia/Manila';
\copy src.queues     FROM 'data/queues.csv'     CSV HEADER
\copy src.agents     FROM 'data/agents.csv'     CSV HEADER
\copy src.calls      FROM 'data/calls.csv'      CSV HEADER
\copy src.chats      FROM 'data/chats.csv'      CSV HEADER
\copy src.faxes      FROM 'data/faxes.csv'      CSV HEADER
\copy src.qa_scores  FROM 'data/qa_scores.csv'  CSV HEADER
GRANT SELECT ON ALL TABLES IN SCHEMA src TO trainee;
