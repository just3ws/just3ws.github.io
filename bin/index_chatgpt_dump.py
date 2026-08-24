#!/usr/bin/env python3
"""
index_chatgpt_dump.py — Index ChatGPT conversation JSON exports into a SQLite FTS5 database.

Usage:
  python3 bin/index_chatgpt_dump.py [--source /path/to/dump] [--db /path/to/output.db]
"""

import os
import glob
import json
import sqlite3
import argparse
import time

DEFAULT_SOURCE = "/Volumes/Dock_1TB/chatgpt-dump-2026-03"
DEFAULT_DB = "/Volumes/Dock_1TB/chatgpt-dump-2026-03/chatgpt_corpus.db"


def init_db(db_path):
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    
    # Enable WAL mode for high concurrency & speed
    cur.execute("PRAGMA journal_mode=WAL;")
    cur.execute("PRAGMA synchronous=NORMAL;")
    
    cur.execute("""
    CREATE TABLE IF NOT EXISTS conversations (
        id TEXT PRIMARY KEY,
        title TEXT,
        create_time REAL,
        update_time REAL,
        default_model TEXT,
        message_count INTEGER
    );
    """)
    
    cur.execute("""
    CREATE TABLE IF NOT EXISTS messages (
        id TEXT PRIMARY KEY,
        conversation_id TEXT,
        author_role TEXT,
        create_time REAL,
        content TEXT,
        FOREIGN KEY (conversation_id) REFERENCES conversations(id)
    );
    """)
    
    cur.execute("""
    CREATE VIRTUAL TABLE IF NOT EXISTS messages_fts USING fts5(
        message_id UNINDEXED,
        conversation_id UNINDEXED,
        title,
        author_role,
        content,
        tokenize='porter unicode61'
    );
    """)
    
    conn.commit()
    return conn


def extract_messages_from_mapping(mapping):
    messages = []
    if not mapping:
        return messages
        
    for node_id, node in mapping.items():
        if not node or not isinstance(node, dict):
            continue
        msg = node.get("message")
        if not msg or not isinstance(msg, dict):
            continue
            
        author = msg.get("author", {})
        role = author.get("role", "unknown") if isinstance(author, dict) else "unknown"
        create_time = msg.get("create_time") or 0.0
        
        content_obj = msg.get("content", {})
        parts_text = []
        if isinstance(content_obj, dict):
            parts = content_obj.get("parts", [])
            if isinstance(parts, list):
                for p in parts:
                    if isinstance(p, str):
                        parts_text.append(p)
                    elif isinstance(p, dict):
                        text = p.get("text") or p.get("fallback")
                        if text:
                            parts_text.append(str(text))
                            
        full_text = "\n".join(parts_text).strip()
        if full_text:
            messages.append({
                "id": msg.get("id") or node_id,
                "role": role,
                "create_time": create_time,
                "content": full_text
            })
            
    messages.sort(key=lambda m: m["create_time"] or 0)
    return messages


def index_dump(source_dir, db_path):
    start_time = time.time()
    print(f"[*] Initializing SQLite database at: {db_path}")
    conn = init_db(db_path)
    cur = conn.cursor()
    
    files = sorted(glob.glob(os.path.join(source_dir, "conversations-*.json")))
    if not files:
        files = sorted(glob.glob(os.path.join(source_dir, "conversations*.json")))
        
    print(f"[*] Found {len(files)} JSON conversation files in {source_dir}")
    
    total_convs = 0
    total_msgs = 0
    
    for fpath in files:
        fname = os.path.basename(fpath)
        print(f"  -> Processing {fname}...")
        try:
            with open(fpath, "r", encoding="utf-8", errors="replace") as f:
                convs = json.load(f)
        except Exception as e:
            print(f"  [!] Error reading {fpath}: {e}")
            continue
            
        conv_batch = []
        msg_batch = []
        fts_batch = []
        
        for c in convs:
            if not isinstance(c, dict):
                continue
            conv_id = c.get("id") or c.get("conversation_id")
            if not conv_id:
                continue
                
            title = c.get("title") or "Untitled"
            create_time = c.get("create_time") or 0.0
            update_time = c.get("update_time") or 0.0
            model = c.get("default_model_slug") or ""
            
            raw_msgs = extract_messages_from_mapping(c.get("mapping", {}))
            msg_count = len(raw_msgs)
            
            conv_batch.append((conv_id, title, create_time, update_time, model, msg_count))
            
            for m in raw_msgs:
                msg_batch.append((m["id"], conv_id, m["role"], m["create_time"], m["content"]))
                fts_batch.append((m["id"], conv_id, title, m["role"], m["content"]))
                
            total_convs += 1
            total_msgs += msg_count
            
        cur.executemany("""
            INSERT OR REPLACE INTO conversations (id, title, create_time, update_time, default_model, message_count)
            VALUES (?, ?, ?, ?, ?, ?);
        """, conv_batch)
        
        cur.executemany("""
            INSERT OR REPLACE INTO messages (id, conversation_id, author_role, create_time, content)
            VALUES (?, ?, ?, ?, ?);
        """, msg_batch)
        
        cur.executemany("""
            INSERT INTO messages_fts (message_id, conversation_id, title, author_role, content)
            VALUES (?, ?, ?, ?, ?);
        """, fts_batch)
        
        conn.commit()
        
    duration = time.time() - start_time
    print(f"\n[✓] Indexing complete in {duration:.2f}s!")
    print(f"    Total Conversations: {total_convs}")
    print(f"    Total Messages:      {total_msgs}")
    print(f"    Database Path:       {db_path} ({os.path.getsize(db_path) / (1024*1024):.1f} MB)")
    conn.close()


def main():
    parser = argparse.ArgumentParser(description="Index ChatGPT JSON exports into SQLite FTS5.")
    parser.add_argument("--source", default=DEFAULT_SOURCE, help=f"Directory containing conversations-*.json (default: {DEFAULT_SOURCE})")
    parser.add_argument("--db", default=DEFAULT_DB, help=f"Target SQLite database path (default: {DEFAULT_DB})")
    args = parser.parse_args()
    
    index_dump(args.source, args.db)


if __name__ == "__main__":
    main()
