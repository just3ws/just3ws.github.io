-- The Postgres Pulse "Smoking Gun" Script
-- Usage: psql $DATABASE_URL -f pulse.sql > results.csv
-- This script extracts performance metrics WITHOUT PII (no user data, no email, no secrets).

-- 1. Check if pg_stat_statements is available
SELECT CASE 
  WHEN count(*) > 0 THEN 'pg_stat_statements is ENABLED' 
  ELSE 'WARNING: pg_stat_statements is NOT enabled. Run: CREATE EXTENSION pg_stat_statements;' 
END as status
FROM pg_extension WHERE extname = 'pg_stat_statements';

-- 2. The "Smoking Gun" Query: Top 20 queries by total execution time
-- This identifies where the most "pain" is being felt by the system.
SELECT 
    queryid,
    calls,
    round(total_exec_time::numeric / 1000, 2) as total_seconds,
    round(mean_exec_time::numeric, 2) as mean_ms,
    round((100 * total_exec_time / sum(total_exec_time) OVER ())::numeric, 2) as percentage_of_total_time,
    rows,
    -- We take a substring of the query to keep the report clean
    substring(query, 1, 200) as query_preview
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 20;

-- 3. The "Wait Event" Snapshot (Active Locks/Blockers)
-- This shows what is happening RIGHT NOW.
SELECT 
    count(*) as active_connections,
    wait_event_type,
    wait_event,
    state
FROM pg_stat_activity
WHERE state != 'idle'
GROUP BY 1, 2, 3, 4
ORDER BY 1 DESC;
