# Reaction and Live Coding Setup Guide

This guide establishes the window management, display scaling, browser settings, and terminal ergonomics for streaming the UGtastic rewatch series on macOS with Apple Silicon.

---

## 1. The Core Screen Real Estate Philosophy

Live technical streams suffer when viewers cannot read the text on screen. Most modern displays are high-density Retina screens (3024x1964 or 4K). If you capture an entire Retina desktop without scaling, viewers watching on 1080p monitors or phones will see tiny, unreadable text.

The project profile fixes the OBS canvas at **1920x1080 (Full HD, 16:9)**. Every scene is designed to render windows, text, and browser players at 1:1 crispness.

---

## 2. Window Management and Workflow Layout

### The Two-Window Reaction Layout

When reacting to an interview video while cross-referencing archival data:
- **Left Pane (Video Playback)**: Chromium browser playing the interview video.
- **Right Pane (Investigation & Research)**: Secondary browser or terminal showing `just3ws.localhost/timeline/community/` or `just3ws.localhost/interviews/`.

```
+-------------------------------------------------------------+
|                     1920x1080 OBS Canvas                    |
| +-------------------------+ +-----------------------------+ |
| |                         | |                             | |
| |   Chromium Browser      | |   Secondary Browser         | |
| |   (UGtastic Interview)  | |   (just3ws.localhost)       | |
| |                         | |   Transcripts & Timeline    | |
| |   Width: 910px          | |   Width: 910px              | |
| |   Height: 512px         | |   Height: 512px             | |
| +-------------------------+ +-----------------------------+ |
|               +-------------------------+                   |
|               |  Host Camera (Inset)    |                   |
|               |  Width: 400px           |                   |
|               +-------------------------+                   |
| [==================== Lower Third HUD ====================] |
+-------------------------------------------------------------+
```

### The Terminal Workbench Layout (Coding & Demonstrations)

When switching to live terminal archaeology, git analysis, or multi-agent demos:
- Switch to **Scene 05 (Workbench - Code & Terminal)**.
- Use a dedicated terminal profile (Ghostty, iTerm2, or macOS Terminal) configured with:
  - Font: JetBrains Mono, SF Mono, or Menlo
  - Font Size: 18pt minimum (ensures crystal clear readability on mobile streams)
  - Color Palette: High contrast dark theme matching the craftsmanship slate palette (`#0d1117`)
  - Window Size: Clean 16:9 ratio or maximized full screen

---

## 3. Chromium Browser Optimization for Video Reaction

When using Chromium as the video playback source:

1. **Clean Window Presentation**:
   Open a clean dedicated profile window, or use app-mode (`--app=URL`) or full-screen (`Cmd+Shift+F`) to eliminate tab bar distractions when capturing a single window.
2. **Native Video Audio Routing**:
   OBS utilizes macOS ScreenCaptureKit application audio capture. It hooks directly into the Chromium process (`org.chromium.Chromium`), capturing the interview audio stream digitally without routing through virtual audio drivers.
3. **Pausing and Scrubbing**:
   Keep keyboard focus on the Chromium window so pressing `Spacebar` pauses the video immediately when you want to interject and comment.
4. **Playback Speed**:
   For slow-paced archival recordings, 1.1x or 1.2x playback speed in Chromium can keep stream momentum high while remaining completely intelligible.
5. **Craftsman Recording Environment & Staged Assets**:
   Maintain and synchronize the dedicated browser profile using `bin/setup_recording_environment.py`:
   - Run `python3 bin/setup_recording_environment.py --sync --verify` to automatically stage unpacked extensions to `~/Library/Application Support/Chromium/UnpackedExtensions/`.
   - Staged configuration backups are version-controlled in `obs/browser-themes/staged-configs/`:
     - `bonjourr-craftsman-settings.json`: Start page cockpit aligned to `#faf8f5` warm paper canvas, Charter display clock, and Inter quicklinks.
     - `stylus-craftsman-theme.json`: Global declutter rules, video antialiasing, amber quote selection, and craftsman YouTube player skin.
     - `ublock-origin-celenity-backup.txt`: Celenity advanced blocking profile paired with LocalCDN library emulation.
   - Quarantined: LastPass, Complexity, and DeArrow are strictly excluded across all recording profiles.

---

## 4. ScreenCaptureKit vs Display Capture

Always use **Window Capture (ScreenCaptureKit)** rather than full Display Capture:

- **Privacy Protection**: ScreenCaptureKit captures only the target application window. If an OS notification, email alert, or private message pops up on your screen, it will not appear on the stream.
- **Occlusion Freedom**: You can place reference notes, chat windows, or terminal prompts partially over the browser window on your physical display; ScreenCaptureKit captures only the rendered contents of the target window.
- **Retina Crispness**: Window capture renders crisp vector text without desktop downscaling artifacts.

---

## 5. Privacy Boundary and PHI Guardrails

In accordance with platform safety policies:
- Never open `.env`, `.zdots.secrets`, or private credential stores during a live stream.
- Keep the terminal session anchored to public repository paths (`~/github.com/just3ws/just3ws.github.io` or `~/.config/zsh`).
- Use the secret scanner (`bin/secret-scan`) before pushing any commits created during live coding sessions.
