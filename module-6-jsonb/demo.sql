-- Module 6 demo. Run as trainee unless a line says "administrator".
SET TIME ZONE 'Asia/Manila';

-- 1. One chat transcript
SELECT chat_id, jsonb_pretty(transcript) AS transcript
FROM src.chats
WHERE transcript IS NOT NULL
ORDER BY chat_id
LIMIT 1;

-- 2. Messages per chat
SELECT chat_id, jsonb_array_length(transcript -> 'messages') AS messages
FROM src.chats
WHERE transcript IS NOT NULL
ORDER BY chat_id
LIMIT 5;

-- 3. Average number of messages in a chat
SELECT round(avg(jsonb_array_length(transcript -> 'messages')), 1) AS avg_messages
FROM src.chats
WHERE transcript IS NOT NULL;

-- 4. Chats where the customer mentioned a bill
SELECT count(*) AS chats_mentioning_bill
FROM src.chats
WHERE jsonb_path_exists(transcript, '$.messages[*] ? (@.sender == "customer" && @.text like_regex "bill")');

-- 5. What do customers say first?
SELECT m ->> 'text' AS first_message, count(*) AS chats
FROM src.chats, jsonb_array_elements(transcript -> 'messages') WITH ORDINALITY AS t(m, n)
WHERE n = 1
GROUP BY 1
ORDER BY chats DESC;

-- 6. Join the JSON back to relational data: chats that opened with "I was charged twice", per queue
SELECT q.queue_name, count(*) AS chats
FROM src.chats c
JOIN src.queues q USING (queue_id)
WHERE c.transcript @> '{"messages": [{"text": "I was charged twice"}]}'
GROUP BY q.queue_name;

-- 7. administrator: an index for JSON lookups
-- EXPLAIN ANALYZE SELECT count(*) FROM src.chats WHERE transcript @> '{"messages": [{"text": "I was charged twice"}]}';
-- CREATE INDEX chats_transcript_gin ON src.chats USING gin (transcript);
-- EXPLAIN ANALYZE SELECT count(*) FROM src.chats WHERE transcript @> '{"messages": [{"text": "I was charged twice"}]}';
-- DROP INDEX src.chats_transcript_gin;
