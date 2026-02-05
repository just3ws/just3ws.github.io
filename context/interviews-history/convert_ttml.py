#!/usr/bin/env python3
"""Convert TTML transcript files to clean text."""

import os
import re
import html
from pathlib import Path

def clean_ttml(content):
    """Extract and clean text from TTML content."""
    # Extract text between <text> tags
    pattern = r'<text[^>]*>([^<]*(?:<[^/][^<]*)*)</text>'
    matches = re.findall(pattern, content)

    lines = []
    for match in matches:
        # First decode HTML entities
        text = html.unescape(match)
        # Remove font and other HTML tags
        text = re.sub(r'<[^>]+>', '', text)
        # Decode any remaining entities
        text = html.unescape(text)
        # Clean up whitespace
        text = ' '.join(text.split())
        if text:
            lines.append(text)

    # Join into paragraphs (every ~10 segments for readability)
    paragraphs = []
    current = []
    for i, line in enumerate(lines):
        current.append(line)
        if (i + 1) % 10 == 0:
            paragraphs.append(' '.join(current))
            current = []
    if current:
        paragraphs.append(' '.join(current))

    return '\n\n'.join(paragraphs)

def slugify(name):
    """Convert filename to clean slug."""
    # Remove extension
    name = Path(name).stem
    # Replace special chars
    name = re.sub(r'[^\w\s-]', '', name)
    # Replace spaces with underscores
    name = re.sub(r'\s+', '_', name)
    return name.lower()

def main():
    source_dir = Path('/Volumes/Dock_1TB/WITC/consolidated/Uploads from WHOIS Tech Community')
    output_dir = Path('/Volumes/Dock_1TB/WITC/_output/transcripts')

    converted = 0
    errors = []

    for ttml_file in sorted(source_dir.glob('*.ttml')):
        try:
            content = ttml_file.read_text(encoding='utf-8')
            clean_text = clean_ttml(content)

            if clean_text.strip():
                output_name = slugify(ttml_file.name) + '.txt'
                output_path = output_dir / output_name
                output_path.write_text(clean_text, encoding='utf-8')
                converted += 1
        except Exception as e:
            errors.append(f"ERROR: {ttml_file.name}: {e}")

    print(f"Converted: {converted}")
    if errors:
        for e in errors:
            print(f"  {e}")

if __name__ == '__main__':
    main()
