#!/usr/bin/env python3
"""
bin/download_vimeo_masters_direct.py

Authenticates with Vimeo using Chrome session cookies, extracts high-res progressive MP4
playback links from the Vimeo API v3 endpoint, and streams the videos directly to
the configured Vimeo directory.
"""

import os
import sys
import re
import json
import http.cookiejar
from curl_cffi import requests

TARGET_DIR = os.environ.get("VIMEO_VIDEOS_DIR", "")
COOKIES_FILE = "tmp/vimeo_cookies.txt"

VIMEO_VIDEOS = [
    {
        "id": "38936294",
        "speaker": "Igor Polevoy",
        "title": "ActiveJDBC & ActiveWeb for Java",
        "filename": "38936294_Igor_Polevoy_ActiveJDBC.mp4"
    },
    {
        "id": "42266284",
        "speaker": "Ralph Iden",
        "title": "Simplest Thing (Follett Software)",
        "filename": "42266284_Ralph_Iden_Simplest_Thing.mp4"
    },
    {
        "id": "42282153",
        "speaker": "Peter Krawczyk & Larry Ullman",
        "title": "Dynamic HTML 5 using jQuery for Perl",
        "filename": "42282153_Peter_Krawczyk_HTML5_jQuery_Perl.mp4"
    },
    {
        "id": "44387717",
        "speaker": "Andy Maleh",
        "title": "Software Craftsmanship VS Software Engineering",
        "filename": "44387717_Andy_Maleh_Software_Craftsmanship_VS_Software_Engineering.mp4"
    }
]

def main():
    print("🎬 Starting Automated Direct Vimeo Master Video Downloader...")
    os.makedirs(TARGET_DIR, exist_ok=True)

    if not os.path.exists(COOKIES_FILE):
        print(f"❌ Error: Cookies file {COOKIES_FILE} not found.")
        sys.exit(1)

    cookie_jar = http.cookiejar.MozillaCookieJar(COOKIES_FILE)
    cookie_jar.load(ignore_discard=True, ignore_expires=True)

    session = requests.Session(impersonate="chrome")
    session.cookies.update(cookie_jar)

    downloaded = 0

    for item in VIMEO_VIDEOS:
        vid = item["id"]
        speaker = item["speaker"]
        title = item["title"]
        target_path = os.path.join(TARGET_DIR, item["filename"])

        if os.path.exists(target_path) and os.path.getsize(target_path) > 10_000_000:
            print(f"✓ [{vid}] Already exists ({os.path.getsize(target_path) / 1024 / 1024:.1f} MB): {item['filename']}")
            continue

        print(f"\n📥 [{vid}] Querying Vimeo API for: {speaker} - {title}...")

        manage_url = f"https://vimeo.com/manage/videos/{vid}"
        res = session.get(manage_url)
        if res.status_code != 200:
            print(f"  ❌ Manage page returned HTTP {res.status_code}")
            continue

        jwt_match = re.search(r"\"jwt\":\s*\"([^\"]+)\"", res.text)
        if not jwt_match:
            print("  ❌ Could not extract JWT token from manage page.")
            continue

        jwt = jwt_match.group(1)

        api_headers = {
            "Authorization": f"jwt {jwt}",
            "Accept": "application/vnd.vimeo.*+json;version=3.4",
            "Referer": manage_url
        }

        api_res = session.get(f"https://api.vimeo.com/videos/{vid}", headers=api_headers)
        if api_res.status_code != 200:
            print(f"  ❌ API returned HTTP {api_res.status_code}")
            continue

        data = api_res.json()
        play = data.get("play", {})
        progressive = play.get("progressive", [])

        if not progressive:
            print(f"  ❌ No progressive MP4 streams available for video {vid}.")
            continue

        progressive.sort(key=lambda x: x.get("width", 0), reverse=True)
        best_stream = progressive[0]
        download_url = best_stream.get("link")
        expected_size = best_stream.get("size", 0)

        print(f"  🎯 Found best stream: {best_stream.get('width')}x{best_stream.get('height')} ({best_stream.get('rendition', 'SD')}) | Size: {expected_size / 1024 / 1024:.1f} MB")
        print(f"  🚀 Downloading to: {target_path}...")

        stream_res = session.get(download_url, stream=True)
        if stream_res.status_code != 200:
            print(f"  ❌ Stream download failed with HTTP {stream_res.status_code}")
            continue

        bytes_written = 0
        with open(target_path, "wb") as f:
            for chunk in stream_res.iter_content(chunk_size=1024 * 1024):
                if chunk:
                    f.write(chunk)
                    bytes_written += len(chunk)
                    if expected_size > 0:
                        pct = (bytes_written / expected_size) * 100.0
                        print(f"\r     Progress: {bytes_written / 1024 / 1024:.1f} / {expected_size / 1024 / 1024:.1f} MB ({pct:.1f}%)", end="", flush=True)

        print(f"\n  ✅ Successfully downloaded {item['filename']} ({bytes_written / 1024 / 1024:.1f} MB)!")
        downloaded += 1

    print(f"\n=======================================================")
    print(f"🎉 Completed Vimeo master downloads! Downloaded: {downloaded} new video(s).")

if __name__ == "__main__":
    main()
