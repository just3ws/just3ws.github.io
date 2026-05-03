# Diagnostic AI Prompts

Use these prompts with local AI (via bin/analyze-behavior) to compress artifacts and cluster evidence.

## 1. Log Reconstruction & Anomaly Clustering
**Input:** Raw Rails logs (with request/correlation IDs).
**Prompt:**
> You are a senior SRE and Rails performance expert. Analyze the provided production logs. 
> 1. Deduplicate requests by Correlation ID.
> 2. Cluster requests into "normal" and "anomalous" paths based on latency, status codes, and database query count.
> 3. Identify silent failures (e.g., 200 OK but with Sidekiq job failures or missing DB commits).
> 4. Summarize the timeline of one representative anomalous request.
> 5. Quote specific log lines as evidence.

## 2. Schema Hotspot & Coupling Analysis
**Input:** schema.rb or structure.sql.
**Prompt:**
> You are a Senior Rails Architect. Analyze this schema. 
> 1. Identify "God tables" (tables with too many relationships or responsibilities).
> 2. Identify missing indexes on foreign keys or commonly queried columns.
> 3. Spot potential data integrity risks (e.g., missing null constraints, lack of foreign key constraints at the DB level).
> 4. Map the behavior surface for [Specific Model/Path].
> 5. Highlight hidden coupling (e.g., polymorphic relationships that might cause N+1 or lock contention).

## 3. Query Bottleneck Analysis (EXPLAIN JSON)
**Input:** Output of EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON).
**Prompt:**
> You are a PostgreSQL Performance Expert. Analyze this JSON execution plan.
> 1. Identify the primary bottleneck (e.g., Seq Scan, Nested Loop, Sort, or IO wait).
> 2. Compare the planner's 'Estimated Cost/Rows' vs the actual 'Execution Time/Rows'. 
> 3. Inspect the 'Buffers' output. Is the query hitting shared buffers or reading from disk?
> 4. Summarize the findings in plain English for a senior developer.
> 5. Propose a specific remediation (e.g., index change, rewrite, or statistics update).

## 4. Query Triage (pg_stat_statements)
**Input:** pg_stat_statements export (CSV).
**Prompt:**
> You are a Database Administrator. Analyze this pg_stat_statements data.
> 1. Rank the top 5 queries by `total_exec_time` (cumulative pain).
> 2. Identify queries with high `mean_exec_time` but low call count (potential outliers).
> 3. Identify queries with high `stddev_exec_time` (unstable performance).
> 4. Cluster queries by their fingerprint (normalized shape).
> 5. Recommend which query to target first for maximum system relief.
