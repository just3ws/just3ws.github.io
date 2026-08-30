import re
import yaml
import html

ttml_path = "/Volumes/Dock_1TB/WITC/consolidated/whoistechcmty/_unsorted/UGtastic/Rip/WHOIS Tech Community - 042 - Interview with Greg Baugues on Mental Health in Tech at RailsConf 2014.mp4.ttml"

with open(ttml_path, "r", encoding="utf-8") as f:
    content = f.read()

matches = re.findall(r'<text start="([^"]+)" dur="([^"]+)">([^<]+(?:<font[^>]*>[^<]*</font>[^<]*)*)</text>', content)

raw_cues = []
for start, dur, raw_text in matches:
    clean_text = re.sub(r'<[^>]+>', '', raw_text)
    clean_text = html.unescape(clean_text).strip()
    if clean_text:
        raw_cues.append({
            "start": float(start),
            "dur": float(dur),
            "text": clean_text
        })

print(f"Parsed {len(raw_cues)} caption cues.")

full_text = " ".join([c["text"] for c in raw_cues])

transcript_data = {
    "speaker_map": {
        "M1": {
            "name": "Mike Hall",
            "role": "Host, UGtastic"
        },
        "S1": {
            "name": "Greg Baugues",
            "role": "Developer Evangelist, Twilio / Table XI"
        }
    },
    "content": full_text
}

with open("_data/transcripts/interview-with-greg-baugues-on-mental-health-in-tech-at-railsconf-2014.yml", "w", encoding="utf-8") as f:
    yaml.dump(transcript_data, f, sort_keys=False, allow_unicode=True)

print("Saved _data/transcripts/interview-with-greg-baugues-on-mental-health-in-tech-at-railsconf-2014.yml successfully!")
