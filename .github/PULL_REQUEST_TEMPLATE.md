## 📝 Summary of Changes

Briefly explain the purpose of this Pull Request (e.g. transcript correction, timestamp adjustment, speaker map update, or historical context addition).

- **Target Transcript / Asset ID:** `id-here`
- **Issue Reference:** Closes #

---

## 🔍 Category of Change
- [ ] **`fix(transcript)`** - Corrected dialogue text, misheard technical terms, or typos
- [ ] **`fix(speaker)`** - Updated speaker map, role titles, or attribution assignments
- [ ] **`fix(timing)`** - Adjusted start/end timestamps or sync boundaries
- [ ] **`docs(context)`** - Enriched historical context, conference metadata, or related links
- [ ] **`feat(archive)`** - Added new transcript or metadata asset

---

## 🧪 Verification & Quality Checklist

Before submitting, verify that all automated checks pass:

- [ ] **Declarative Validation:** Ran `bundle exec rake validate:data_uniqueness validate:data_integrity` cleanly.
- [ ] **Jekyll Build & A11y Check:** Ran `bundle exec jekyll build` with 0 warnings.
- [ ] **Local Player Visual Verification:** Tested the changes locally on `http://127.0.0.1:4000/interviews/<slug>/` in both **Light Nord** and **Dark Kanagawa Wave** modes.
- [ ] **Synchronized Transcript Test:** Verified that timestamp clicks (`⏱ MM:SS`) jump to the exact audio turn cleanly without player errors.
- [ ] **WebVTT / Captions Sync:** Updated caption sidecars/manifests if timestamps or text turns were modified.
