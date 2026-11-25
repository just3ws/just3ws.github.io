#!/usr/bin/env python3
"""
---
name: download_podcast_episode
domain: media
purpose: Resilient multi-chunk podcast audio downloader with byte-range verification, feed search, and ztranscribe handoff
usage: bin/download_podcast_episode.py [url] [--feed url] [--search query] [-o output_path] [-w workers] [-c chunk_mb] [--transcribe]
description: Overcomes podcast CDN rate-limiting, session resets, and analytics proxy
  delays (Podtrac, Simplecast AIS, Megaphone, Libsyn) by using IPv4 socket resolution,
  bounded chunk sizes, block-level streaming, automated ffmpeg validation, and direct
  handoff to ztranscribe.
---
# ponytail: multi-threaded chunked downloader using Python standard library (urllib + http.client);
# upgrade trigger: migrate to a full async/aiohttp daemon if batching entire multi-season archives concurrently.
"""

import argparse
import http.client
import os
import re
import socket
import subprocess
import sys
import time
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
from concurrent.futures import ThreadPoolExecutor, as_completed

# Force IPv4 socket resolution to prevent macOS IPv6 CDN stalls
orig_getaddrinfo = socket.getaddrinfo


def ipv4_getaddrinfo(host, port, family=0, type=0, proto=0, flags=0):
    return orig_getaddrinfo(host, port, socket.AF_INET, type, proto, flags)


socket.getaddrinfo = ipv4_getaddrinfo

DEFAULT_UA = "Podcasts/1660.10 CFNetwork/1498.700.2 Darwin/23.6.0"


def clean_enclosure_url(url: str) -> str:
    """Strip known tracking redirect wrappers if present."""
    podtrac_prefix = "https://dts.podtrac.com/redirect.mp3/"
    if url.startswith(podtrac_prefix):
        stripped = url[len(podtrac_prefix):]
        if not stripped.startswith("http"):
            stripped = "https://" + stripped
        return stripped
    return url


def parse_feed_episodes(feed_url: str, user_agent: str = DEFAULT_UA):
    """Fetch and parse RSS feed items."""
    req = urllib.request.Request(feed_url, headers={"User-Agent": user_agent})
    with urllib.request.urlopen(req, timeout=30) as resp:
        tree = ET.fromstring(resp.read())

    channel = tree.find("channel")
    if channel is None:
        raise ValueError("Invalid RSS feed: missing <channel> tag")

    episodes = []
    for it in channel.findall("item"):
        title_el = it.find("title")
        title = title_el.text.strip() if title_el is not None and title_el.text else "Untitled"
        enc = it.find("enclosure")
        enc_url = enc.attrib.get("url") if enc is not None else None
        length = enc.attrib.get("length") if enc is not None else None
        pub_date_el = it.find("pubDate")
        pub_date = pub_date_el.text.strip() if pub_date_el is not None and pub_date_el.text else ""
        if enc_url:
            episodes.append({
                "title": title,
                "url": enc_url,
                "length": int(length) if length and length.isdigit() else 0,
                "pub_date": pub_date
            })
    return episodes


def search_feed_episode(feed_url: str, search_query: str, user_agent: str = DEFAULT_UA):
    """Find the best matching episode in an RSS feed."""
    episodes = parse_feed_episodes(feed_url, user_agent=user_agent)
    
    # 1. Exact match (case insensitive)
    for ep in episodes:
        if ep["title"].strip().lower() == search_query.strip().lower():
            return ep, episodes

    # 2. Word boundary regex match (e.g. \bCan Pt II\b won't match \bCan Pt III\b)
    word_pattern = re.compile(r"\b" + re.escape(search_query.strip()) + r"\b", re.IGNORECASE)
    word_matches = [ep for ep in episodes if word_pattern.search(ep["title"])]
    if word_matches:
        return word_matches[0], episodes

    # 3. Substring match
    sub_matches = [ep for ep in episodes if search_query.lower() in ep["title"].lower()]
    if sub_matches:
        return sub_matches[0], episodes

    # 4. Fallback to all individual words present
    words = search_query.lower().split()
    all_word_matches = [ep for ep in episodes if all(w in ep["title"].lower() for w in words)]
    if all_word_matches:
        return all_word_matches[0], episodes

    raise ValueError(f"No episode found matching '{search_query}' in feed {feed_url}")


def resolve_stream(url: str, user_agent: str = DEFAULT_UA, max_redirects: int = 10):
    """Follow redirects to determine final streaming URL and content length."""
    current_url = url
    for _ in range(max_redirects):
        req = urllib.request.Request(
            current_url,
            headers={"User-Agent": user_agent, "Accept": "*/*"}
        )
        try:
            with urllib.request.urlopen(req, timeout=20) as resp:
                final_url = resp.geturl()
                content_length = resp.headers.get("Content-Length")
                accept_ranges = resp.headers.get("Accept-Ranges", "")
                supports_ranges = "bytes" in accept_ranges.lower()
                size = int(content_length) if content_length else 0
                return final_url, size, supports_ranges
        except urllib.error.HTTPError as e:
            if e.code in (301, 302, 303, 307, 308):
                location = e.headers.get("Location")
                if location:
                    current_url = urllib.parse.urljoin(current_url, location)
                    continue
            raise
    raise RuntimeError(f"Too many redirects resolving {url}")


def download_chunk(url: str, dest_path: str, idx: int, start: int, end: int, user_agent: str, max_retries: int = 5):
    """Download a single byte range reading in 64KB blocks and write into destination file offset."""
    expected_bytes = end - start + 1
    headers = {
        "Range": f"bytes={start}-{end}",
        "User-Agent": user_agent,
        "Accept": "*/*",
        "Connection": "close"
    }

    for attempt in range(1, max_retries + 1):
        try:
            req = urllib.request.Request(url, headers=headers)
            received = 0
            with urllib.request.urlopen(req, timeout=60) as resp, open(dest_path, "r+b") as out_f:
                out_f.seek(start)
                while True:
                    buf = resp.read(65536)
                    if not buf:
                        break
                    out_f.write(buf)
                    received += len(buf)

                if received != expected_bytes:
                    raise IOError(f"Chunk {idx} received {received} bytes; expected {expected_bytes}")
                return idx, received
        except Exception as e:
            if attempt == max_retries:
                raise RuntimeError(f"Chunk {idx} (bytes {start}-{end}) failed after {max_retries} attempts: {e}")
            backoff = attempt * 2
            time.sleep(backoff)


def download_podcast_episode(url: str, output_path: str, workers: int = 6, chunk_mb: float = 2.0, user_agent: str = DEFAULT_UA):
    """Orchestrate chunked download with validation."""
    clean_url = clean_enclosure_url(url)
    print(f"Resolving stream for {clean_url[:70]}...")
    final_url, total_size, supports_ranges = resolve_stream(clean_url, user_agent=user_agent)

    print(f"Direct stream URL: {final_url[:80]}...")
    print(f"Content length: {total_size} bytes ({total_size / (1024*1024):.2f} MB)")
    print(f"Supports range requests: {supports_ranges}")

    os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)

    if not supports_ranges or total_size == 0 or workers <= 1:
        print("Falling back to single-stream download...")
        req = urllib.request.Request(final_url, headers={"User-Agent": user_agent})
        with urllib.request.urlopen(req, timeout=120) as resp, open(output_path, "wb") as out_f:
            while True:
                buf = resp.read(65536)
                if not buf:
                    break
                out_f.write(buf)
        return output_path

    # Pre-allocate output file
    with open(output_path, "wb") as f:
        f.truncate(total_size)

    chunk_size = int(chunk_mb * 1024 * 1024)
    ranges = []
    curr = 0
    idx = 0
    while curr < total_size:
        end = min(curr + chunk_size - 1, total_size - 1)
        ranges.append((idx, curr, end))
        curr = end + 1
        idx += 1

    total_chunks = len(ranges)
    print(f"Starting chunked download across {workers} parallel IPv4 workers ({total_chunks} chunks of ~{chunk_mb} MB)...")
    start_time = time.time()
    completed_chunks = 0
    total_bytes = 0

    with ThreadPoolExecutor(max_workers=workers) as executor:
        future_map = {
            executor.submit(download_chunk, final_url, output_path, r[0], r[1], r[2], user_agent): r[0]
            for r in ranges
        }
        for future in as_completed(future_map):
            idx, nbytes = future.result()
            completed_chunks += 1
            total_bytes += nbytes
            elapsed = time.time() - start_time
            rate_mb = (total_bytes / (1024 * 1024)) / elapsed if elapsed > 0 else 0
            pct = (completed_chunks / total_chunks) * 100
            print(f"  [{completed_chunks:02d}/{total_chunks:02d} - {pct:5.1f}%] Chunk {idx:02d} complete ({nbytes / 1024:.1f} KB) at {rate_mb:.2f} MB/s", flush=True)

    total_time = time.time() - start_time
    avg_speed = (total_bytes / (1024 * 1024)) / total_time if total_time > 0 else 0
    print(f"Download complete: {output_path} ({total_bytes / (1024*1024):.2f} MB in {total_time:.1f}s, avg {avg_speed:.2f} MB/s)")

    # Integrity verification
    print("Verifying audio container integrity with ffmpeg...")
    probe = subprocess.run(
        ["ffmpeg", "-v", "error", "-i", output_path, "-f", "null", "-"],
        capture_output=True,
        text=True
    )
    if probe.returncode != 0:
        print(f"Warning: ffmpeg validation error:\n{probe.stderr}", file=sys.stderr)
        raise RuntimeError(f"Audio file failed ffmpeg validation: {probe.stderr}")

    print("Audio verification check passed: zero container decode errors.")
    return output_path


def slugify(title: str) -> str:
    """Convert title to filesystem safe slug."""
    s = title.lower()
    s = re.sub(r"[^\w\s-]", "", s)
    s = re.sub(r"[-\s]+", "-", s).strip("-")
    return s


def main():
    parser = argparse.ArgumentParser(description="Resilient chunked podcast downloader")
    parser.add_argument("url", nargs="?", help="Podcast audio enclosure URL (or feed URL when using --search)")
    parser.add_argument("--feed", help="Podcast RSS feed URL to query")
    parser.add_argument("--search", help="Episode title or query to find within RSS feed")
    parser.add_argument("--list", action="store_true", help="List episodes in RSS feed")
    parser.add_argument("--dry-run", action="store_true", help="Search and display matched episode without downloading")
    parser.add_argument("-o", "--output", help="Destination audio file path (defaults to ~/Downloads/<slug>.mp3)")
    parser.add_argument("-w", "--workers", type=int, default=6, help="Number of concurrent download workers (default 6)")
    parser.add_argument("-c", "--chunk-size", type=float, default=2.0, help="Chunk size in MB (default 2.0)")
    parser.add_argument("-u", "--user-agent", default=DEFAULT_UA, help="User agent string")
    parser.add_argument("--transcribe", action="store_true", help="Execute ztranscribe directly on the downloaded audio")

    args = parser.parse_args()

    feed_url = args.feed or (args.url if (args.url and ("feed" in args.url or "rss" in args.url or args.search or args.list)) else None)
    audio_url = args.url if (args.url and not feed_url) else None

    if args.list:
        if not feed_url:
            parser.error("--list requires an RSS feed URL via --feed or positional argument")
        episodes = parse_feed_episodes(feed_url, user_agent=args.user_agent)
        print(f"Episodes in feed ({len(episodes)} total):")
        for i, ep in enumerate(episodes[:20], 1):
            print(f"  [{i:02d}] {ep['title']} ({ep['pub_date']}) - {ep['length'] / (1024*1024):.1f} MB")
        return

    if args.search:
        if not feed_url:
            parser.error("--search requires an RSS feed URL via --feed or positional argument")
        match, _ = search_feed_episode(feed_url, args.search, user_agent=args.user_agent)
        print(f"Found episode: {match['title']} ({match['pub_date']})")
        print(f"  Length: {match['length'] / (1024*1024):.2f} MB")
        print(f"  Audio URL: {match['url']}")
        if args.dry_run:
            return
        audio_url = match["url"]
        if not args.output:
            args.output = os.path.expanduser(f"~/Downloads/{slugify(match['title'])}.mp3")

    if not audio_url:
        parser.error("Must supply an audio URL or an RSS feed with --search")

    if not args.output:
        base_name = os.path.basename(urllib.parse.urlparse(audio_url).path) or "podcast_episode.mp3"
        args.output = os.path.expanduser(f"~/Downloads/{base_name}")

    out_file = download_podcast_episode(
        audio_url,
        args.output,
        workers=args.workers,
        chunk_mb=args.chunk_size,
        user_agent=args.user_agent
    )

    if args.transcribe:
        ztranscribe_bin = os.path.expanduser("~/.config/zsh/bin/ztranscribe")
        if not os.path.exists(ztranscribe_bin):
            ztranscribe_bin = "ztranscribe"
        print(f"\nLaunching ztranscribe on {out_file}...")
        subprocess.run([ztranscribe_bin, out_file], check=True)


if __name__ == "__main__":
    main()
