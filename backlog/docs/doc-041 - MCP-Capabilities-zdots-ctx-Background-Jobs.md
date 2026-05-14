---
id: doc-041
title: 'MCP Capabilities: zdots-ctx Background Jobs'
type: guide
created_date: '2026-05-14 23:37'
tags:
  - mcp
  - capabilities
  - transcription
  - zdots-ctx
---
# MCP Capabilities: zdots-ctx Background Jobs

This workspace exposes a local Context MCP Server (`ctx-mcp`) that allows AI agents to interact with the Zdots Intelligence Suite, including queuing background side-effect jobs like high-performance video transcription.

## Available MCP Tools

AI agents interacting with this system have access to the following tools via the `ctx-mcp` server:

- **`ctx_enqueue`**: Enqueue a new side-effect job.
  - `type`: 'transcription'
  - `payload_json`: JSON string. For transcription, use `{"url": "<youtube_url>", "video_asset_id": "<canonical_id>"}`
- **`ctx_jobs`**: List pending, running, and recently completed jobs.

## Workflow: Automated Transcription

When an AI agent needs to transcribe a YouTube video, it should follow this asynchronous pattern rather than running blocking synchronous commands:

1. **Enqueue the Job**
   Call the `ctx_enqueue` tool:
   ```json
   {
     "type": "transcription",
     "payload_json": "{\"url\": \"https://www.youtube.com/watch?v=VIDEO_ID\", \"video_asset_id\": \"my-canonical-id\"}"
   }
   ```

2. **Ensure the Worker is Running**
   The jobs are processed by the `zdots-ctx` background worker. The agent should ensure the worker is running using a shell execution tool.
   *CRITICAL RULE:* To prevent the underlying `ffmpeg` process from hanging while waiting for terminal input, the worker MUST be started with standard input redirected from `/dev/null`:
   ```bash
   zdots-ctx worker --type transcription < /dev/null &
   ```

3. **Monitor Progress**
   The agent can use the `ctx_jobs` tool to check if the transcription job has transitioned from `pending` to `running` and then to `completed` or `failed`.

4. **Handling Failures / Interruptions**
   If the worker process is interrupted or hung (e.g., jobs stuck in `running` for an abnormally long time), the agent should:
   - Kill the hung worker processes.
   - Clear stale jobs back to pending: `zdots-ctx clear-stale-jobs`
   - Restart the worker safely: `zdots-ctx worker --type transcription < /dev/null &`

5. **Post-Processing**
   Once the job is completed, the transcript will be output to `~/Downloads/transcripts/<VIDEO_ID>/`. The agent can then use the project's ingestion scripts (`bin/stage_completed_transcripts.rb` and `bin/transcripts ingest`) to move the data into the repository.
