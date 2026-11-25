#!/usr/bin/env python3
"""
---
name: cleanup_can_transcript
domain: media
purpose: Normalize Whisper phonetic distortions in Can transcripts against verified primary sources
usage: bin/cleanup_can_transcript.py <transcript_dir_or_file>
description: Replaces Whisper misheard proper nouns, German band member names, album
  titles, studios, and book references with canonical ground truth verified against
  official episode show notes, All Gates Open (Rob Young & Irmin Schmidt), The Can Box
  (Hildegard Schmidt & Wolf Kampmann), and Krautrock history.
---
# ponytail: regex-based dictionary replacements with context sensitivity;
# upgrade trigger: migrate to an LLM semantic entity resolution pipeline if expanding to 100+ distinct bands.
"""

import os
import re
import sys

# Canonical Entity Mapping (Regex pattern -> Canonical replacement)
CAN_REPLACEMENTS = [
    # Band Names & Krautrock terms
    (r"\b[Cc]rot\s+rock\b", "Krautrock"),
    (r"\b[Cc]rout\s+rock\b", "Krautrock"),
    (r"\b[Kk]raut\s+rock\b", "Krautrock"),
    (r"\b[Kk]rautreich\b", "Krautrock"),
    (r"\bCannes\b(?!\s+(?:film|festival|France|palme|croisette))", "Can"),
    (r"\bcannes\b", "Can"),
    (r"\bCan'\b", "Can's"),
    (r"\bKant's\s+instant\s+compositions\b", "Can's instant compositions"),
    (r"\b[Kk]en\s+would\s+record\b", "Can would record"),
    (r"\bSo\s+[Kk]en\s+slowly\b", "So Can slowly"),
    (r"\bSo\s+[Kk]en\s+was\s+out\b", "So Can was out"),
    (r"\bwhen\s+[Kk]en\s+showed\s+up\b", "when Can showed up"),
    (r"\bwhen\s+[Kk]en\s+was\s+playing\b", "when Can was playing"),
    (r"\bthe\s+[Kk]en\s+members\b", "the Can members"),
    (r"\bfor\s+[Kk]en\s+at\b", "for Can at"),
    (r"\bopened\s+for\s+[Cc]annes\b", "opened for Can"),
    (r"\b[Kk]en\s+showed\s+up\b", "Can showed up"),
    (r"\b[Kk]en\s+was\s+playing\b", "Can was playing"),

    # Members - Irmin Schmidt
    (r"\b(?:Ehrman|Ermin|ermin|ermine|Armin|Herman|herman)\s+Schmidt\b", "Irmin Schmidt"),
    (r"\b(?:Ehrman|Ermin|ermin|ermine|Armin)\b", "Irmin"),

    # Members - Holger Czukay
    (r"\b[Hh]olger\s+(?:Tchouke|Chuke|Chuket|Chouquet|Czukay|Schukay|Zukay|Shookay)\b", "Holger Czukay"),
    (r"\bthe\s+(?:Tchouke|Chuke|Chuket|Chouquet)\s+family\b", "the Czukay family"),
    (r"\bHolger\s+Chukay\b", "Holger Czukay"),
    (r"\bTchouke\b", "Czukay"),

    # Members - Jaki Liebezeit
    (r"\b(?:Jackie|Jacky|jackie|jacky|Yaki)\s+(?:Levisite|Liebezeit|Lee\s+Bezai|Lee\s+Bezeit|Liebeszeit|libizite|Libeside|libeside)\b", "Jaki Liebezeit"),
    (r"\b(?:Jackie|Jacky|jackie|jacky)\s+Liebezeit\b", "Jaki Liebezeit"),
    (r"\bJaki\s+Liebeszeit\b", "Jaki Liebezeit"),
    (r"\b(?:Jackie|Jacky|jackie|jacky)\b", "Jaki"),

    # Members - Michael Karoli
    (r"\bMichael\s+(?:Caroli|Corolli|Crowley|Carolli|Karolyi)\b", "Michael Karoli"),
    (r"\bmichael\s+(?:caroli|corolli|crowley|carolli|karolyi)\b", "Michael Karoli"),
    (r"\b(?:Caroli|Corolli|Carolli|Karolyi)\b", "Karoli"),

    # Members - Malcolm Mooney & Damo Suzuki
    (r"\bMalcom\s+Mooney\b", "Malcolm Mooney"),
    (r"\b(?:Damu|Domo)\s+Suzuki\b", "Damo Suzuki"),

    # Locations, Castles & Studios
    (r"\bCastle\s+(?:Norvinage|Norvenich|Norvingen|Norvignage)\b", "Schloss Nörvenich"),
    (r"\bSchloss\s+Norvenich\b", "Schloss Nörvenich"),
    (r"\b(?:Weillerswist|Weillischwist|Weilischwist|Weilerswist)\b", "Weilerswist"),
    (r"\b(?:Inner|Inter)\s*Space\s+Studios?\b", "Inner Space Studio"),

    # Related Krautrock bands & soundtrack works
    (r"\bAmundul\s+2\b", "Amon Düül II"),
    (r"\bAmundul\b", "Amon Düül"),
    (r"\bAmandul\s+2\b", "Amon Düül II"),
    (r"\bAmandul\b", "Amon Düül"),
    (r"\bAmadou\s+2\b", "Amon Düül II"),
    (r"\bAmadou\b", "Amon Düül"),
    (r"\bPopel\s+Vogue\b", "Popol Vuh"),
    (r"\bMielenspiele\b", "Millionenspiel"),

    # Collaborators & Teachers
    (r"\bKarl\s+Heinz\s+Stockhausen\b", "Karlheinz Stockhausen"),
    (r"\bCarl\s+Heinz\s+Stockhausen\b", "Karlheinz Stockhausen"),
    (r"\bWolf\s+(?:Koppelman|Koppman|Katman)\b", "Wolf Kampmann"),
    (r"\bPascal\s+Bussey\b", "Pascal Bussy"),
    (r"\bJono\s+Podmore\b", "Jono Podmore"),
    (r"\bHildegard\s+Schmidt\b", "Hildegard Schmidt"),
    (r"\bChristoph\s+Vohwinkel\b", "Christoph Vohwinkel"),
    (r"\bDavid\s+Johnson\b", "David Johnson"),
    (r"\bAbby\s+Offerham\b", "Abi Ofarim"),
    (r"\bI\s+Am\s+Dam[ao]\s+Suzuki\b", "I Am Damo Suzuki"),

    # Albums & Books
    (r"\bTago\s+Mago\b", "Tago Mago"),
    (r"\bTagomago\b", "Tago Mago"),
    (r"\btago\s+mago\b", "Tago Mago"),
    (r"\btagamago\b", "Tago Mago"),
    (r"\bTango\s+Mago\b", "Tago Mago"),
    (r"\bTaco\s+Mago\b", "Tago Mago"),
    (r"\btaco\s+mago\b", "Tago Mago"),
    (r"\bEge\s+Bamyasi\b", "Ege Bamyasi"),
    (r"\bEgg\s+Bamyasi\b", "Ege Bamyasi"),
    (r"\bEG\s+Bamyasi\b", "Ege Bamyasi"),
    (r"\bEgi\s+Bamyasi\b", "Ege Bamyasi"),
    (r"\b[Ii]ga\s+[Bb]amiyasi\b", "Ege Bamyasi"),
    (r"\b[Dd]ead\s+[Pp]igeon\s+[Ss]uite\b", "Dead Pigeon Suite"),
    (r"\bFuture\s+Days\b", "Future Days"),
    (r"\bMonster\s+Movie\b", "Monster Movie"),
    (r"\bSoundtracks\b", "Soundtracks"),
    (r"\bSoon\s+Over\s+Babaluma\b", "Soon Over Babaluma"),
    (r"\bLanded\b", "Landed"),
    (r"\bFlow\s+Motion\b", "Flow Motion"),
    (r"\bSaw\s+Delight\b", "Saw Delight"),
    (r"\bAll\s+Gates\s+Open\b", "All Gates Open"),
    (r"\bThe\s+Can\s+Box\b", "The Can Box"),
    (r"\bKrautrocksampler\b", "Krautrocksampler"),
    (r"\b(?:Ohm|Alm)\b(?=.*(?:17\s+minutes|Tago\s+Mago|song|record|Aumgn))", "Aumgn"),
    (r"\bthe\s+song\s+(?:Ohm|Alm)\b", "the song Aumgn"),
    (r"\btrack\s+(?:Ohm|Alm)\b", "track Aumgn"),
    (r"\bended\s+with\s+Ohm\b", "ended with Aumgn"),
    (r"\bpeeking\s+out\b(?=.*(?:bring\s+me\s+coffee|Tago\s+Mago|songs|album))", "Peking O"),
    (r"\bpeeking\s+out\s+and\s+bring\s+me\s+coffee\b", "Peking O and Bring Me Coffee"),

    # Later Collaborators & Engineers
    (r"\b(?:Rene|René)\s+Tinner\b", "René Tinner"),
    (r"\bRoscoe\s+Gee\b", "Rosko Gee"),
    (r"\bRebop\b(?:\s+Kwaku\s+Baah)?", "Rebop Kwaku Baah"),
]


def clean_text(text: str) -> str:
    """Apply all canonical entity substitutions to text."""
    for pattern, replacement in CAN_REPLACEMENTS:
        text = re.sub(pattern, replacement, text)
    return text


def process_file(file_path: str):
    """Process a single transcript file and output a cleaned version."""
    if not os.path.exists(file_path):
        print(f"Error: file not found {file_path}", file=sys.stderr)
        return

    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    cleaned = clean_text(content)

    base, ext = os.path.splitext(file_path)
    if base.endswith(".cleaned"):
        out_path = file_path
    else:
        out_path = f"{base}.cleaned{ext}"

    with open(out_path, "w", encoding="utf-8") as f:
        f.write(cleaned)

    diff_count = sum(1 for line1, line2 in zip(content.splitlines(), cleaned.splitlines()) if line1 != line2)
    print(f"Cleaned {file_path} -> {out_path} ({diff_count} lines updated)")
    return out_path


def process_directory(dir_path: str):
    """Process all transcript formats (.txt, .srt, .vtt) in a directory."""
    if not os.path.isdir(dir_path):
        print(f"Error: directory not found {dir_path}", file=sys.stderr)
        return

    for root, _, files in os.walk(dir_path):
        for f in files:
            if f.endswith((".txt", ".srt", ".vtt")) and not f.endswith(".cleaned.txt") and not f.endswith(".cleaned.srt") and not f.endswith(".cleaned.vtt"):
                process_file(os.path.join(root, f))


def main():
    if len(sys.argv) < 2:
        print("Usage: bin/cleanup_can_transcript.py <transcript_file_or_dir>")
        sys.exit(1)

    target = sys.argv[1]
    if os.path.isdir(target):
        process_directory(target)
    else:
        process_file(target)


if __name__ == "__main__":
    main()
