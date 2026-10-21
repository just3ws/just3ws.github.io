#!/usr/bin/env python3

# ---
# name: setup_recording_environment.py
# domain: media
# purpose: Setup Recording Environment utility for the just3ws platform
# usage: python3 bin/setup_recording_environment.py
# ---

"""
Toolchain for setting up, verifying, and updating the recording browser environment.
Ensures Ungoogled Chromium is equipped with essential recording extensions, themes,
and verified configs (uBlock Origin Celenity profile, Stylus craftsman userstyles,
Bonjourr craftsman start page settings).

Strict policy:
- No LastPass, Complexity, or DeArrow.
- Em-dash free.
"""

import sys
import os
import re
import json
import struct
import zipfile
import io
import urllib.request
import argparse

VERSION = "1.1.0"
CHROMIUM_APP = "/Applications/Chromium.app"
DEFAULT_TARGET_BASE = os.path.expanduser("~/Library/Application Support/Chromium/UnpackedExtensions")
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
CRAFTSMAN_THEME_SRC = os.path.join(PROJECT_ROOT, "obs", "browser-themes", "chromium-craftsman-theme")
STAGED_CONFIGS_DIR = os.path.join(PROJECT_ROOT, "obs", "browser-themes", "staged-configs")
UBLOCK_BACKUP_DEST = os.path.expanduser("~/Downloads/ublock-origin-celenity-backup.txt")
STYLUS_BACKUP_DEST = os.path.expanduser("~/Downloads/stylus-craftsman-theme.json")
BONJOURR_BACKUP_DEST = os.path.expanduser("~/Downloads/bonjourr-craftsman-settings.json")
UBLOCK_REPO_DEST = os.path.join(STAGED_CONFIGS_DIR, "ublock-origin-celenity-backup.txt")
STYLUS_REPO_DEST = os.path.join(STAGED_CONFIGS_DIR, "stylus-craftsman-theme.json")
BONJOURR_REPO_DEST = os.path.join(STAGED_CONFIGS_DIR, "bonjourr-craftsman-settings.json")

HDR = {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.7390.55 Safari/537.36"
}

# Declarative extension inventory (Quarantined: LastPass, Complexity, DeArrow)
RECORDING_EXTENSIONS = [
    {
        "id": "ublock-origin",
        "name": "uBlock Origin",
        "type": "github_zip",
        "repo": "gorhill/uBlock",
        "asset_pattern": r"uBlock0_.*\.chromium\.zip",
        "description": "Content blocker with custom Celenity configuration"
    },
    {
        "id": "sponsorblock",
        "name": "SponsorBlock for YouTube",
        "type": "github_zip",
        "repo": "ajayyy/SponsorBlock",
        "asset_pattern": r"ChromeExtension\.zip",
        "description": "Crowdsourced sponsor segment skipper"
    },
    {
        "id": "return-youtube-dislike",
        "name": "Return YouTube Dislike",
        "type": "github_zip",
        "repo": "Anarios/return-youtube-dislike",
        "asset_pattern": r"return-youtube-dislike-chrome-.*\.zip",
        "description": "Restores public dislike counters"
    },
    {
        "id": "dark-reader",
        "name": "Dark Reader",
        "type": "github_zip",
        "repo": "darkreader/darkreader",
        "asset_pattern": r"darkreader-chrome-mv3\.zip",
        "description": "Universal dark theme engine"
    },
    {
        "id": "stylus",
        "name": "Stylus",
        "type": "github_zip",
        "repo": "openstyles/stylus",
        "asset_pattern": r"stylus-chrome-mv3-.*\.zip",
        "description": "Userstyle manager for stream-safe broadcast CSS"
    },
    {
        "id": "localcdn",
        "name": "LocalCDN",
        "type": "codeberg_xpi",
        "repo": "nobody/LocalCDN",
        "description": "Local asset emulation for tracker-free third-party libraries"
    },
    {
        "id": "chromium-web-store",
        "name": "Chromium Web Store Helper",
        "type": "github_crx",
        "repo": "NeverDecaf/chromium-web-store",
        "asset_pattern": r"Chromium\.Web\.Store\.crx",
        "description": "Enables Web Store installations and updates inside Chromium"
    },
    {
        "id": "ambient-light-for-youtube",
        "name": "Ambient Light for YouTube",
        "type": "cws_crx",
        "ext_id": "paponcgjfojgemddooebbgniglhkajkj",
        "description": "Dynamic bias lighting surrounding video canvas"
    },
    {
        "id": "youtube-high-definition",
        "name": "YouTube High Definition",
        "type": "cws_crx",
        "ext_id": "dokdlgjaaaijndfajoknjbelmadhomca",
        "description": "Auto resolution locking for pristine recording clarity"
    },
    {
        "id": "enhancer-for-youtube",
        "name": "Enhancer for YouTube",
        "type": "cws_crx",
        "ext_id": "ponfpcnoihfmfllpaingbgckeeldkhle",
        "description": "Player control suite and cinema mode layout"
    },
    {
        "id": "bonjourr-start-page",
        "name": "Bonjourr Start Page",
        "type": "cws_crx",
        "ext_id": "dlnejlppicbjfcfcedcflplfjajinajd",
        "description": "Minimalist clean new-tab page free of search ads"
    },
    {
        "id": "clear-cache",
        "name": "Clear Cache",
        "type": "cws_crx",
        "ext_id": "cppjkneekbjaeellbfkmgnhonkkjfpdn",
        "description": "Single-click clean session reset before takes"
    },
    {
        "id": "hister",
        "name": "Hister",
        "type": "cws_crx",
        "ext_id": "cciilamhchpmbdnniabclekddabkifhb",
        "description": "Companion full-text browsing history indexer for hister.localhost"
    },
    {
        "id": "read-aloud",
        "name": "Read Aloud Voice Reader",
        "type": "cws_crx",
        "ext_id": "hdhinadidafjejdhmfkjgnolgimiaplp",
        "description": "Select text and play aloud via text to speech"
    }
]

PROHIBITED_EXTENSIONS = ["lastpass", "complexity", "dearrow"]


def unpack_crx3(data: bytes, out_dir: str):
    """Unpack a CRX3 binary into a target directory."""
    magic, version, header_size = struct.unpack("<4sII", data[:12])
    if magic != b"Cr24":
        raise ValueError(f"Invalid CRX header: {magic}")
    zip_bytes = data[12 + header_size:]
    os.makedirs(out_dir, exist_ok=True)
    with zipfile.ZipFile(io.BytesIO(zip_bytes)) as z:
        z.extractall(out_dir)


def extract_zip(data: bytes, out_dir: str):
    """Extract a ZIP archive and flatten single-directory nesting if present."""
    os.makedirs(out_dir, exist_ok=True)
    with zipfile.ZipFile(io.BytesIO(data)) as z:
        z.extractall(out_dir)

    subdirs = [f for f in os.listdir(out_dir) if not f.startswith(".")]
    if len(subdirs) == 1 and os.path.isdir(os.path.join(out_dir, subdirs[0])):
        nested_dir = os.path.join(out_dir, subdirs[0])
        if os.path.exists(os.path.join(nested_dir, "manifest.json")):
            for item in os.listdir(nested_dir):
                os.rename(os.path.join(nested_dir, item), os.path.join(out_dir, item))
            os.rmdir(nested_dir)


def fetch_github_asset_url(repo: str, pattern: str) -> str:
    """Fetch the latest release download URL matching a pattern from GitHub."""
    api_url = f"https://api.github.com/repos/{repo}/releases/latest"
    req = urllib.request.Request(api_url, headers=HDR)
    with urllib.request.urlopen(req, timeout=15) as resp:
        data = json.loads(resp.read().decode("utf-8"))
        for asset in data.get("assets", []):
            if re.search(pattern, asset["name"]):
                return asset["browser_download_url"]
    raise RuntimeError(f"No asset matching {pattern} found in {repo} releases")


def fetch_codeberg_xpi_url(repo: str) -> str:
    """Fetch the latest release download URL for a Codeberg repository."""
    api_url = f"https://codeberg.org/api/v1/repos/{repo}/releases?page=1&limit=1"
    req = urllib.request.Request(api_url, headers=HDR)
    with urllib.request.urlopen(req, timeout=15) as resp:
        data = json.loads(resp.read().decode("utf-8"))
        if data and "assets" in data[0] and data[0]["assets"]:
            return data[0]["assets"][0]["browser_download_url"]
    raise RuntimeError(f"No release asset found in Codeberg repo {repo}")


def fetch_cws_crx_data(ext_id: str) -> bytes:
    """Fetch CRX3 binary from the Chrome Web Store Omaha update endpoint."""
    url = (
        f"https://clients2.google.com/service/update2/crx?response=redirect"
        f"&prod=chromecrx&prodchannel=&prodversion=141.0.7390.55&lang=en-US"
        f"&acceptformat=crx3,puff&x=id%3D{ext_id}%26installsource%3Dondemand%26uc"
    )
    req = urllib.request.Request(url, headers=HDR)
    with urllib.request.urlopen(req, timeout=25) as resp:
        return resp.read()


def install_extension(ext: dict, target_base: str, dry_run: bool = False):
    """Download and install or update an individual extension."""
    ext_id = ext["id"]
    out_dir = os.path.join(target_base, ext_id)
    print(f" -> Checking {ext['name']} ({ext_id})...")

    if dry_run:
        print(f"    [dry-run] Would sync {ext['name']} into {out_dir}")
        return

    ext_type = ext["type"]
    if ext_type == "github_zip":
        url = fetch_github_asset_url(ext["repo"], ext["asset_pattern"])
        req = urllib.request.Request(url, headers=HDR)
        with urllib.request.urlopen(req, timeout=30) as resp:
            extract_zip(resp.read(), out_dir)
    elif ext_type == "github_crx":
        url = fetch_github_asset_url(ext["repo"], ext["asset_pattern"])
        req = urllib.request.Request(url, headers=HDR)
        with urllib.request.urlopen(req, timeout=30) as resp:
            unpack_crx3(resp.read(), out_dir)
    elif ext_type == "codeberg_xpi":
        url = fetch_codeberg_xpi_url(ext["repo"])
        req = urllib.request.Request(url, headers=HDR)
        with urllib.request.urlopen(req, timeout=30) as resp:
            extract_zip(resp.read(), out_dir)
    elif ext_type == "cws_crx":
        data = fetch_cws_crx_data(ext["ext_id"])
        unpack_crx3(data, out_dir)

    manifest_path = os.path.join(out_dir, "manifest.json")
    if os.path.exists(manifest_path):
        with open(manifest_path, "r", encoding="utf-8") as f:
            manifest = json.load(f)
            version = manifest.get("version", "unknown")
            mv = manifest.get("manifest_version", "?")
            print(f"    [OK] Installed v{version} (MV{mv})")
    else:
        print(f"    [WARNING] manifest.json missing in {out_dir}")


def sync_craftsman_theme(target_base: str, dry_run: bool = False):
    """Sync the repository Craftsman Theme into the unpacked extensions folder."""
    theme_dest = os.path.join(target_base, "the-sound-above-theme")
    print(" -> Syncing The Sound Above Craftsman Theme...")
    if dry_run:
        print(f"    [dry-run] Would sync theme from {CRAFTSMAN_THEME_SRC} to {theme_dest}")
        return

    os.makedirs(theme_dest, exist_ok=True)
    manifest_src = os.path.join(CRAFTSMAN_THEME_SRC, "manifest.json")
    manifest_dest = os.path.join(theme_dest, "manifest.json")
    with open(manifest_src, "r", encoding="utf-8") as sf:
        content = sf.read()
    with open(manifest_dest, "w", encoding="utf-8") as df:
        df.write(content)
    print(f"    [OK] Theme manifest synced to {theme_dest}")


def generate_ublock_backup():
    """Generate the Celenity uBlock Origin configuration backup file."""
    print(" -> Generating uBlock Origin Celenity configuration backup...")
    my_filters = """! Celenity recommendations
xn--*
xn--*$doc,popup,frame
||doubleclick.net^$important
||google-analytics.com^$important
||facebook.com^$important,third-party
||facebook.net^$important,third-party
||linkedin.com^$important,third-party
||instagram.com^$important,third-party
||tiktok.com^$important,third-party
||twitter.com^$third-party,domain=~x.com
||x.com^$third-party
||gravatar.com^$important,third-party
||accounts.google.com^$third-party,domain=~chromium.org|~gstatic.com|~googleusercontent.com|~youtube.com
||appleid.apple.com^$third-party,domain=~appleid.cdn-apple.com
||appleid.cdn-apple.com^$third-party,domain=~appleid.apple.com
||challenges.cloudflare.com^$third-party
@@||challenges.cloudflare.com/cdn-cgi/challenge-platform/$third-party,script,frame
||www.google.com^$third-party,subdocument
@@||www.google.com/recaptcha/$third-party,subdocument
||www.gstatic.com^$third-party,script
@@||www.gstatic.com/recaptcha/$third-party,script
"""

    dynamic_filtering_string = """* * 3p block
* * 3p-frame block
* * 3p-script block
* challenges.cloudflare.com * noop
* www.google.com * noop
* www.gstatic.com * noop
* hcaptcha.com * noop
* recaptcha.net * noop
x.com twitter.com * noop
twitter.com x.com * noop
* ajax.googleapis.com * noop
* ajax.aspnetcdn.com * noop
* ajax.microsoft.com * noop
* cdnjs.cloudflare.com * noop
* code.jquery.com * noop
* cdn.jsdelivr.net * noop
* fonts.googleapis.com * noop
* yastatic.net * noop
* yandex.st * noop
* apps.bdimg.com * noop
* libs.baidu.com * noop
* cdn.staticfile.org * noop
* cdn.bootcss.com * noop
* mat1.gtimg.com * noop
* lib.sinaapp.com * noop
* upcdn.b0.upaiyun.com * noop
* stackpath.bootstrapcdn.com * noop
* maxcdn.bootstrapcdn.com * noop
* netdna.bootstrapcdn.com * noop
* use.fontawesome.com * noop
* ajax.cloudflare.com * noop
* akamai-webcdn.kgstatic.net * noop
* gitcdn.github.io * noop
* vjs.zencdn.net * noop
* cdn.plyr.io * noop
* cdn.materialdesignicons.com * noop
* cdn.ravenjs.com * noop
* js.appboycdn.com * noop
* cdn.embed.ly * noop
* cdn.datatables.net * noop
* mathjax.rstudio.com * noop
* cdn.mathjax.org * noop
* code.createjs.com * noop
* sdn.geekzu.org * noop
* ajax.proxy.ustclug.org * noop
* unpkg.com * noop
* pagecdn.io * noop
* cdnjs.loli.net * noop
* ajax.loli.net * noop
* fonts.loli.net * noop
* lib.baomitu.com * noop
* cdn.bootcdn.net * noop
* fonts.gstatic.com * noop
* ajax.loli.net.cdn.cloudflare.net * noop
* akamai-webcdn.kgstatic.net.edgesuite.net * noop
* apps.bdimg.jomodns.com * noop
* cdn.bootcdn.net.maoyundns.com * noop
* cdn.bootcss.com.maoyundns.com * noop
* cdn.embed.ly.cdn.cloudflare.net * noop
* cdn.jsdelivr.net.cdn.cloudflare.net * noop
* cdnjs.loli.net.cdn.cloudflare.net * noop
* cds.s5x3j6q5.hwcdn.net * noop
* developer.n.shifen.com * noop
* dualstack.osff.map.fastly.net * noop
* fonts.loli.net.cdn.cloudflare.net * noop
* gateway.cname.ustclug.org * noop
* iduwdjf.qiniudns.com * noop
* lb.sae.sina.com.cn * noop
* lib.baomitu.com.qh-cdn.com * noop
* mat1.gtimg.com.tegsea.tc.qq.com * noop
* materialdesignicons.b-cdn.net * noop
* mscomajax.vo.msecnd.net * noop
* sdn.inbond.gslb.geekzu.org * noop
* use.fontawesome.com.cdn.cloudflare.net * noop
* vo.aicdn.com * noop"""

    backup_data = {
        "timeStamp": 1728835000000,
        "version": "1.75.0",
        "userSettings": {
            "advancedUserEnabled": True,
            "autoUpdate": True,
            "cloudStorageEnabled": False,
            "collapseBlocked": True,
            "colorBlindFriendly": False,
            "externalLists": "",
            "hyperlinkAuditingDisabled": True,
            "ignoreGenericCosmeticFilters": False,
            "parseAllABPHideFilters": True,
            "prefetchingDisabled": True,
            "requestLogMaxEntries": 1000,
            "showIconBadge": True,
            "suspendUntilListsAreLoaded": True,
            "webrtcIPAddressHidden": True
        },
        "hiddenSettings": {
            "autoCommentFilterTemplate": "{{url}}",
            "autoUpdateDelayAfterLaunch": 10,
            "disableWebAssembly": True,
            "filterAuthorMode": True,
            "updateAssetBypassBrowserCache": True
        },
        "selectedFilterLists": [
            "user-filters",
            "ublock-filters",
            "ublock-badware",
            "ublock-privacy",
            "ublock-quick-fixes",
            "ublock-unbreak",
            "easylist",
            "adguard-mobile",
            "easyprivacy",
            "adguard-spyware-url",
            "block-lan",
            "urlhaus-1",
            "plowe-0",
            "dpollock-0",
            "easylist-chat",
            "easylist-newsletters",
            "easylist-notifications",
            "easylist-annoyances",
            "fanboy-cookiemonster",
            "fanboy-social"
        ],
        "netWhitelist": "",
        "userFilters": my_filters,
        "dynamicFilteringString": dynamic_filtering_string
    }

    os.makedirs(STAGED_CONFIGS_DIR, exist_ok=True)
    with open(UBLOCK_BACKUP_DEST, "w", encoding="utf-8") as f:
        json.dump(backup_data, f, indent=2)
    with open(UBLOCK_REPO_DEST, "w", encoding="utf-8") as f:
        json.dump(backup_data, f, indent=2)
    print(f"    [OK] Saved Celenity config to {UBLOCK_BACKUP_DEST} and {UBLOCK_REPO_DEST}")


def generate_stylus_backup():
    """Generate the Stylus broadcast userstyles backup file matching the site's palette."""
    print(" -> Generating Stylus broadcast userstyles backup...")
    stylus_global = """/* The Sound Above: Digital Patina & Editorial Craft (Global Web) */
:root {
  --tsa-paper: #faf8f5 !important;
  --tsa-ink: #1e232a !important;
  --tsa-heading: #0f172a !important;
  --tsa-teal: #0f766e !important;
  --tsa-amber: #b45309 !important;
}

/* Eliminate clutter, consent banners, and popovers on stream */
div[class*="cookie-banner"],
div[class*="consent-banner"],
div[class*="newsletter-popup"],
div[id*="cookie-notice"],
#onetrust-banner-sdk {
  display: none !important;
}

/* Smooth, high-legibility antialiasing for downscaled video */
html, body {
  -webkit-font-smoothing: antialiased !important;
  text-rendering: optimizeLegibility !important;
}

/* Archival quotes selection in warm leather amber */
mark, ::selection {
  background: rgba(180, 83, 9, 0.28) !important;
  color: inherit !important;
}

/* Subtle Craftsman scrollbars matching just3ws.localhost */
::-webkit-scrollbar {
  width: 7px !important;
  height: 7px !important;
}
::-webkit-scrollbar-track {
  background: #f4f0e8 !important;
}
::-webkit-scrollbar-thumb {
  background: #0f766e !important;
  border-radius: 4px !important;
}
::-webkit-scrollbar-thumb:hover {
  background: #115e59 !important;
}
"""

    stylus_youtube = """/* The Sound Above: YouTube Craftsman Broadcast Skin */
:root {
  --yt-spec-brand-button-background: #0f766e !important;
  --yt-spec-static-brand-red: #0f766e !important;
}

/* Scrubber bar and active playback progress in craftsman teal */
.ytp-play-progress, .ytp-scrubber-button {
  background: #0f766e !important;
}

/* Progress hover buffer */
.ytp-load-progress {
  background: rgba(15, 118, 110, 0.35) !important;
}

/* Video chapters & timestamps */
.ytp-chapter-hover-bar {
  background: #b45309 !important;
}

/* Hide distracting YouTube clutter during reaction broadcasts */
#secondary #chat,
ytd-mealbar-promo-renderer,
ytd-statement-banner-renderer,
.ytp-suggested-action-badge,
.ytp-cards-teaser {
  display: none !important;
}
"""

    stylus_backup = [
        {
            "id": 1,
            "name": "The Sound Above: Craftsman Broadcast Style (Global)",
            "enabled": True,
            "sections": [
                {
                    "code": stylus_global,
                    "urls": [],
                    "urlPrefixes": [],
                    "domains": [],
                    "regexps": []
                }
            ],
            "updateUrl": None,
            "md5Url": None,
            "url": None
        },
        {
            "id": 2,
            "name": "The Sound Above: YouTube Craftsman Player",
            "enabled": True,
            "sections": [
                {
                    "code": stylus_youtube,
                    "urls": [],
                    "urlPrefixes": ["https://www.youtube.com/"],
                    "domains": ["youtube.com"],
                    "regexps": []
                }
            ],
            "updateUrl": None,
            "md5Url": None,
            "url": None
        }
    ]

    with open(STYLUS_BACKUP_DEST, "w", encoding="utf-8") as f:
        json.dump(stylus_backup, f, indent=2)
    with open(STYLUS_REPO_DEST, "w", encoding="utf-8") as f:
        json.dump(stylus_backup, f, indent=2)
    print(f"    [OK] Saved Stylus theme to {STYLUS_BACKUP_DEST} and {STYLUS_REPO_DEST}")


def generate_bonjourr_backup():
    """Generate the Bonjourr Start Page configuration backup file with craftsman aesthetics."""
    print(" -> Generating Bonjourr Start Page craftsman settings backup...")
    bonjourr_custom_css = """/* Canonical Digital Patina & Editorial Craft (derived from https://www.just3ws.localhost/) */
:root {
  --canvas: #faf8f5 !important;
  --card-bg: #ffffff !important;
  --ink: #1e232a !important;
  --heading: #0f172a !important;
  --muted: #525866 !important;
  --teal: #0f766e !important;
  --teal-light: rgba(15, 118, 110, 0.1) !important;
  --amber: #b45309 !important;
  --border: #e3dfd7 !important;
}

#interface {
  font-family: "Charter", "Bitstream Charter", "Iowan Old Style", Georgia, serif !important;
  color: #1e232a !important;
}

#clock, #time {
  font-family: "Charter", "Bitstream Charter", "Iowan Old Style", Georgia, serif !important;
  font-weight: 700 !important;
  letter-spacing: -0.025em !important;
  color: #0f172a !important;
  text-shadow: none !important;
}

#greetings, #date {
  font-family: "Inter", system-ui, -apple-system, sans-serif !important;
  letter-spacing: 0.1em !important;
  text-transform: uppercase !important;
  font-size: 0.82rem !important;
  font-weight: 700 !important;
  color: #0f766e !important;
  text-shadow: none !important;
}

.link, .link-item {
  background: #ffffff !important;
  border: 1px solid #e3dfd7 !important;
  border-radius: 10px !important;
  box-shadow: 0 4px 16px rgba(45, 35, 20, 0.05) !important;
  transition: all 0.2s ease !important;
}

.link:hover, .link-item:hover {
  border-color: #0f766e !important;
  transform: translateY(-2px) !important;
  box-shadow: 0 8px 24px rgba(15, 118, 110, 0.15) !important;
}

.link-title {
  font-family: "Inter", system-ui, sans-serif !important;
  font-size: 0.85rem !important;
  font-weight: 600 !important;
  color: #1e232a !important;
}
"""

    bonjourr_config = {
        "showall": True,
        "lang": "en",
        "dark": "disabled",
        "favicon": "studio",
        "tabtitle": "Mike Hall · Studio Cockpit",
        "greeting": "Observable Control Plane",
        "greetingsize": "3",
        "greetingsmode": "custom",
        "pagegap": 2,
        "pagewidth": 1280,
        "time": True,
        "main": True,
        "dateformat": "us",
        "quicklinks": True,
        "textShadow": 0,
        "css": bonjourr_custom_css,
        "backgrounds": {
            "type": "color",
            "color": "#faf8f5",
            "bright": 1.0,
            "blur": 0,
            "texture": {
                "type": "none",
                "opacity": 0,
                "size": 0
            }
        },
        "clock": {
            "size": 1.2,
            "ampm": False,
            "analog": False,
            "seconds": False,
            "ampmlabel": False,
            "ampmposition": "top-left",
            "worldclocks": False,
            "timezone": "auto"
        },
        "links_1": {
            "_id": "links_1",
            "title": "Control Plane Dashboard",
            "url": "https://www.just3ws.localhost/dashboard.html",
            "parent": "default",
            "order": 0
        },
        "links_2": {
            "_id": "links_2",
            "title": "Chicago Community Timeline",
            "url": "https://www.just3ws.localhost/timeline/community/",
            "parent": "default",
            "order": 1
        },
        "links_3": {
            "_id": "links_3",
            "title": "Oral History Archive",
            "url": "https://www.just3ws.localhost/interviews/",
            "parent": "default",
            "order": 2
        },
        "links_4": {
            "_id": "links_4",
            "title": "The Sound Above Curriculum",
            "url": "https://www.just3ws.localhost/series/the-sound-above/",
            "parent": "default",
            "order": 3
        },
        "links_5": {
            "_id": "links_5",
            "title": "YouTube Studio Live",
            "url": "https://studio.youtube.com/channel/UCAyLLkogK2UnjpGmyCTwjiw/livestreaming",
            "parent": "default",
            "order": 4
        }
    }

    with open(BONJOURR_BACKUP_DEST, "w", encoding="utf-8") as f:
        json.dump(bonjourr_config, f, indent=2)
    with open(BONJOURR_REPO_DEST, "w", encoding="utf-8") as f:
        json.dump(bonjourr_config, f, indent=2)
    print(f"    [OK] Saved Bonjourr config to {BONJOURR_BACKUP_DEST} and {BONJOURR_REPO_DEST}")


def verify_environment(target_base: str) -> bool:
    """Audit installed extensions and themes against security and cleanliness rules."""
    print("==================================================================")
    print(" 🔍 Auditing Recording Browser Environment")
    print("==================================================================")

    if os.path.isdir(CHROMIUM_APP):
        print(f"✓ Found Chromium application: {CHROMIUM_APP}")
    else:
        print(f"❌ Chromium application not found at {CHROMIUM_APP}")
        return False

    # Quarantine checks
    for prohibited in PROHIBITED_EXTENSIONS:
        p_dir = os.path.join(target_base, prohibited)
        if os.path.exists(p_dir):
            print(f"❌ Policy Violation: Prohibited directory found in {p_dir}")
            print(f"   Removing {prohibited} immediately...")
            import shutil
            shutil.rmtree(p_dir)
            print(f"   ✓ Removed {prohibited}")
        else:
            print(f"✓ Verified: {prohibited} is not present")

    # Extension inventory status
    all_ok = True
    print("\nExtension Inventory:")
    for ext in RECORDING_EXTENSIONS:
        ext_dir = os.path.join(target_base, ext["id"])
        manifest_file = os.path.join(ext_dir, "manifest.json")
        if os.path.exists(manifest_file):
            try:
                with open(manifest_file, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    version = data.get("version", "?")
                    mv = data.get("manifest_version", "?")
                    print(f"  [OK] {ext['name']:32} | v{version:<8} | MV{mv}")
            except Exception as e:
                print(f"  [ERR] {ext['name']:32} | Invalid JSON: {e}")
                all_ok = False
        else:
            print(f"  [MISSING] {ext['name']:32} (id: {ext['id']})")
            all_ok = False

    # Craftsman Theme status
    theme_manifest = os.path.join(target_base, "the-sound-above-theme", "manifest.json")
    if os.path.exists(theme_manifest):
        print("  [OK] The Sound Above: Craftsman Theme | Active")
    else:
        print("  [MISSING] The Sound Above: Craftsman Theme")
        all_ok = False

    # Staged profile configurations
    print("\nStaged Configurations:")
    for path, desc in [
        (UBLOCK_BACKUP_DEST, "uBlock Origin Celenity Profile Backup"),
        (STYLUS_BACKUP_DEST, "Stylus Craftsman Broadcast Userstyles Backup"),
        (BONJOURR_BACKUP_DEST, "Bonjourr Start Page Craftsman Settings Backup")
    ]:
        if os.path.exists(path):
            print(f"  [OK] {desc} -> {path}")
        else:
            print(f"  [MISSING] {desc} -> {path}")
            all_ok = False

    return all_ok


def main():
    parser = argparse.ArgumentParser(
        description="Toolchain to setup, update, and verify the recording browser environment."
    )
    parser.add_argument("--sync", action="store_true", help="Download and sync all extensions and theme assets")
    parser.add_argument("--verify", action="store_true", help="Verify integrity of recording environment")
    parser.add_argument("--dry-run", action="store_true", help="Simulate actions without writing to disk")
    parser.add_argument("--dir", default=DEFAULT_TARGET_BASE, help="Target unpacked extensions base directory")
    args = parser.parse_args()

    if not args.sync and not args.verify:
        args.sync = True
        args.verify = True

    target_base = os.path.expanduser(args.dir)

    print("==================================================================")
    print(f" 🎬 Recording Environment Toolchain v{VERSION}")
    print(f"    Target directory: {target_base}")
    if args.dry_run:
        print("    MODE: DRY-RUN")
    print("==================================================================")

    if args.sync:
        print("\n[Phase 1: Syncing Extensions & Assets]")
        os.makedirs(target_base, exist_ok=True)
        for ext in RECORDING_EXTENSIONS:
            try:
                install_extension(ext, target_base, dry_run=args.dry_run)
            except Exception as e:
                print(f"    ❌ Error syncing {ext['name']}: {e}")

        sync_craftsman_theme(target_base, dry_run=args.dry_run)

        if not args.dry_run:
            generate_ublock_backup()
            generate_stylus_backup()
            generate_bonjourr_backup()

    if args.verify:
        print("\n[Phase 2: Verifying Environment Integrity]")
        success = verify_environment(target_base)
        if success:
            print("\n✅ All recording extensions, themes, and backups are verified and intact.")
        else:
            print("\n⚠️ Environment verification reported missing or damaged components.")
            sys.exit(1)


if __name__ == "__main__":
    main()
