#!/usr/bin/env python3
"""
duck_search.py — Analytical & BM25 Full-Text Search across ChatGPT corpus using DuckDB.

Usage:
  python3 bin/duck_search.py "OpenTelemetry"
  python3 bin/duck_search.py --sql "SELECT count(*), default_model FROM conversations GROUP BY default_model"
"""

import sys
import os
import duckdb
import argparse

DEFAULT_DUCK_DB = "/Volumes/Dock_1TB/chatgpt-dump-2026-03/chatgpt_corpus.duckdb"


def run_fts(query, db_path, limit=10):
    con = duckdb.connect(db_path, read_only=True)
    con.execute("INSTALL fts; LOAD fts;")
    
    sql = """
    SELECT 
        c.title,
        m.author_role,
        strftime(to_timestamp(m.create_time), '%Y-%m-%d %H:%M') as date,
        fts_main_messages.match_bm25(m.id, ?) as score,
        m.content
    FROM messages m
    JOIN conversations c ON m.conversation_id = c.id
    WHERE score IS NOT NULL
    ORDER BY score DESC
    LIMIT ?;
    """
    
    res = con.execute(sql, [query, limit]).fetchall()
    print(f"\n🦆 [DuckDB FTS] Query: '{query}' ({len(res)} matches)\n" + "="*70)
    for i, r in enumerate(res, 1):
        title, author, dt_str, score, content = r
        print(f"[{i}] {title} | {author.upper()} ({dt_str}) — Score: {score:.2f}")
        preview = content.strip().replace('\n', ' ')
        if len(preview) > 300:
            preview = preview[:300] + "..."
        print(f"    {preview}\n")
        print("-" * 70)
    con.close()


def run_sql(sql, db_path):
    con = duckdb.connect(db_path, read_only=True)
    con.execute("INSTALL fts; LOAD fts;")
    print(f"\n🦆 [DuckDB SQL]:\n{sql}\n" + "="*70)
    try:
        df = con.execute(sql).df()
        print(df.to_string(index=False))
    except Exception as e:
        print(f"[!] SQL Error: {e}")
    con.close()


def main():
    parser = argparse.ArgumentParser(description="DuckDB search & analytics for ChatGPT corpus.")
    parser.add_argument("query", nargs="?", help="Search terms for BM25 full-text search")
    parser.add_argument("--sql", help="Run arbitrary analytical SQL query")
    parser.add_argument("--limit", type=int, default=10, help="Limit results (default: 10)")
    parser.add_argument("--db", default=DEFAULT_DUCK_DB, help=f"DuckDB path (default: {DEFAULT_DUCK_DB})")
    args = parser.parse_args()
    
    if args.sql:
        run_sql(args.sql, args.db)
    elif args.query:
        run_fts(args.query, args.db, limit=args.limit)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
