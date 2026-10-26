---
id: TASK-407
title: "Implement Local Vector and Text Search with RubyLLM and YouTube Visibility Controls"
status: Completed
category: media
created_date: '2026-10-26 08:08'
completed_date: '2026-10-26 08:27'
type: feature
priority: high
tags:
  - media-pipeline
  - ruby-llm
  - pgvector
  - full-text-search
  - hybrid-rag
  - youtube-api
  - visibility-controls
---

## Description
<!-- SECTION:DESCRIPTION:BEGIN -->
Implements end-to-end local text search, vector embeddings, and LLM intelligence in `media-pipeline`, paired with direct YouTube visibility controls on media asset screens:

1. **YouTube Video Visibility & Upstream Management Surface**:
   - Provide direct 1-click visibility toggles (`Public`, `Unlisted`, `Private`) on the media asset show screen (`/media_assets/:id`).
   - Add upstream synchronization methods (`set_privacy`, `sync_captions`, `sync_playlist`, `refresh_stats`).
   - Allow instant visibility promotion or private vaulting without requiring the full edit form.

2. **Local Vector & Full-Text Search with RubyLLM**:
   - Enable PostgreSQL 18 `vector` extension (`pgvector`) with HNSW cosine distance indexing.
   - Integrate `ruby_llm` configured to leverage local zdots Apple Silicon Metal GPU servers:
     - Port 11500: Local Chat & Analysis Model (`http://127.0.0.1:11500/v1`)
     - Port 11501: Local Nomic Embeddings Model (`http://127.0.0.1:11501/v1`, 768 dimensions)
   - Chunk video transcripts into timestamp-accurate semantic segments (`MediaAssetChunk`) with start/end playback seconds.
   - Implement hybrid search combining PostgreSQL lexical FTS (`tsvector` with GIN index) and vector semantic similarity via Reciprocal Rank Fusion (RRF).

3. **Operations Cockpit Intelligence UI**:
   - Add a dedicated Intelligence & Semantic Search tab to the Operations Cockpit.
   - Support natural language queries, exact keyword searches, and conversational RAG answers citing exact video timestamps.
<!-- SECTION:DESCRIPTION:END -->

## Execution Plan
<!-- SECTION:PLAN:BEGIN -->
- [x] Step 1: Implement YouTube visibility toggle and upstream management actions on `MediaAsset` and `MediaAssetsController`.
- [x] Step 2: Update `/media_assets/:id` view with 1-click visibility toggles and YouTube operations toolbar.
- [x] Step 3: Run RubyLLM and pgvector migrations for `media_assets` and `media_asset_chunks`.
- [x] Step 4: Configure `ruby_llm.rb` initializer to connect to local zdots daemons on ports 11500 and 11501.
- [x] Step 5: Implement `TranscriptChunkerService`, `EmbeddingService`, and `MediaSearchService`.
- [x] Step 6: Build Intelligence search interface and RAG Q&A in the Operations Cockpit.
- [x] Step 7: Write RSpec specs, verify all linters, and ensure zero em dashes.
<!-- SECTION:PLAN:END -->
