#!/usr/bin/env python3
"""Build master catalog from Vimeo and YouTube metadata."""

import os
import re
import json
from pathlib import Path

def parse_vimeo_json(filepath):
    """Extract info from Vimeo JSON metadata."""
    try:
        with open(filepath) as f:
            data = json.load(f)
        return {
            'title': data.get('title', ''),
            'url': data.get('url', ''),
            'authors': data.get('authors', []),
            'preview_image': data.get('previewImageURL', ''),
            'width': data.get('width'),
            'height': data.get('height'),
        }
    except:
        return None

def parse_youtube_json(filepath):
    """Extract info from YouTube JSON metadata."""
    try:
        with open(filepath) as f:
            data = json.load(f)
        return {
            'title': data.get('title', ''),
            'id': data.get('id', ''),
            'channel': data.get('channel', ''),
            'upload_date': data.get('upload_date', ''),
            'description': data.get('description', ''),
            'duration': data.get('duration'),
            'view_count': data.get('view_count'),
        }
    except:
        return None

def extract_subject_event(title):
    """Parse interview title to extract subject and event."""
    # Pattern: "Interview with X at/@ Event"
    patterns = [
        r'^Interview with (.+?) (?:at|@) (.+)$',
        r'^Interview with (.+)$',
        r'^(.+)$',
    ]

    for pattern in patterns:
        match = re.match(pattern, title, re.IGNORECASE)
        if match:
            groups = match.groups()
            subject = groups[0].strip() if len(groups) > 0 else title
            event = groups[1].strip() if len(groups) > 1 else None
            return subject, event

    return title, None

def main():
    catalog = []
    seen_titles = set()

    # Process Vimeo metadata
    vimeo_dir = Path('/Volumes/Dock_1TB/WITC/Vimeo')
    for json_file in vimeo_dir.glob('*.json'):
        data = parse_vimeo_json(json_file)
        if data and data['title']:
            title = data['title']
            if title not in seen_titles:
                subject, event = extract_subject_event(title)
                catalog.append({
                    'title': title,
                    'subject': subject,
                    'event': event,
                    'source': 'vimeo',
                    'vimeo_url': data['url'],
                    'thumbnail': data['preview_image'],
                })
                seen_titles.add(title)

    # Process YouTube metadata
    youtube_dir = Path('/Volumes/Dock_1TB/WITC/YouTube/Uploads from Mike Hall/_json')
    for json_file in youtube_dir.glob('*.json'):
        data = parse_youtube_json(json_file)
        if data and data['title']:
            title = data['title']
            if title not in seen_titles:
                subject, event = extract_subject_event(title)
                catalog.append({
                    'title': title,
                    'subject': subject,
                    'event': event,
                    'source': 'youtube',
                    'youtube_id': data['id'],
                    'upload_date': data['upload_date'],
                    'duration': data['duration'],
                    'description': data.get('description', '')[:500],
                })
                seen_titles.add(title)

    # Check for transcript availability
    transcript_dir = Path('/Volumes/Dock_1TB/WITC/_output/transcripts')
    transcript_files = {f.stem.lower() for f in transcript_dir.glob('*.txt')}

    for item in catalog:
        # Create slug to match transcript
        slug = re.sub(r'[^\w\s-]', '', item['title'].lower())
        slug = re.sub(r'\s+', '_', slug)
        item['has_transcript'] = slug in transcript_files or any(
            slug in tf for tf in transcript_files
        )

    # Sort by subject name
    catalog.sort(key=lambda x: x['subject'].lower())

    # Write full catalog
    output_path = Path('/Volumes/Dock_1TB/WITC/_output/catalog.json')
    with open(output_path, 'w') as f:
        json.dump(catalog, f, indent=2)

    print(f"Catalog entries: {len(catalog)}")
    print(f"With transcripts: {sum(1 for c in catalog if c.get('has_transcript'))}")

    # Also create simplified CSV for easy viewing
    csv_path = Path('/Volumes/Dock_1TB/WITC/_output/catalog.csv')
    with open(csv_path, 'w') as f:
        f.write('subject,event,source,has_transcript\n')
        for item in catalog:
            event = item['event'] or ''
            has_t = 'yes' if item.get('has_transcript') else 'no'
            f.write(f'"{item["subject"]}","{event}",{item["source"]},{has_t}\n')

    print(f"CSV written to: {csv_path}")

if __name__ == '__main__':
    main()
