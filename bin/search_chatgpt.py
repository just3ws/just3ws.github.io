#!/usr/bin/env python3
"""
search_chatgpt.py — Fast FTS5 search across the indexed ChatGPT corpus.

Usage:
  python3 bin/search_chatgpt.py "OpenTelemetry Working Group"
  python3 bin/search_chatgpt.py "Instant Prequalification" --limit 5
"""

import sys
import os
import sqlite3
import argparse
from datetime import datetime

DEFAULT_DB = os.environ.get("CHATGPT_CORPUS_DB", "")


def search(query, db_path, limit=10, role=None):
    if not os.path.exists(db_path):
        print(f"[!] Database not found at: {db_path}")
        print("    Please run: python3 bin/index_chatgpt_dump.py")
        sys.exit(1)
        
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    
    # Format query for FTS5 (handle multi-word phrases)
    fts_query = query.replace('"', '""')
    
    sql = """
    SELECT 
        m.conversation_id,
        c.title,
        m.author_role,
        m.create_time,
        snippet(messages_fts, 4, '\033[1;31m', '\033[0m', '...', 32) as match_snippet,
        m.content
    FROM messages_fts f
    JOIN messages m ON f.message_id = m.id
    JOIN conversations c ON m.conversation_id = c.id
    WHERE messages_fts MATCH ?
    """
    params = [fts_query]
    
    if role:
        sql += " AND m.author_role = ?"
        params.append(role)
        
    sql += " ORDER BY rank LIMIT ?"
    params.append(limit)
    
    try:
        cur.execute(sql, params)
        rows = cur.fetchall()
    except sqlite3.OperationalError as e:
        # Fallback to simple phrase search
        escaped = f'"{fts_query}"'
        params[0] = escaped
        cur.execute(sql, params)
        rows = cur.fetchall()
        
    print(f"\n🔍 Search Results for: '{query}' (Found {len(rows)} matches)\n" + "="*70)
    
    for i, r in enumerate(rows, 1):
        conv_id, title, author, ts, snippet_text, full_content = r
        dt_str = datetime.fromtimestamp(ts).strftime("%Y-%m-%d %H:%M") if ts else "Unknown Date"
        print(f"[{i}] {title} | {author.upper()} ({dt_str})")
        print(f"    Conversation ID: {conv_id}")
        print(f"    Match:\n    {snippet_text.strip()}\n")
        print("-" * 70)
        
    conn.close()


def main():
    parser = argparse.ArgumentParser(description="Query ChatGPT corpus using SQLite FTS5.")
    parser.add_argument("query", help="Search terms (e.g. 'OpenTelemetry', 'enablement')")
    parser.add_argument("--db", default=DEFAULT_DB, help=f"Corpus database path (default: {DEFAULT_DB})")
    parser.add_argument("--limit", type=int, default=10, help="Max results to display (default: 10)")
    parser.add_argument("--role", choices=["user", "assistant", "system", "tool"], help="Filter by author role")
    args = parser.parse_args()
    
    search(args.query, args.db, limit=args.limit, role=args.role)


if __name__ == "__main__":
    main()
