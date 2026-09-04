---
name: tmi-auditor
description: >
  Audit public-facing site content for oversharing (TMI), discrimination-vector
  signals (*ism guards: ageism, ableism, classism, familism), and PII/PHI
  exposure. Walks the sitemap.xml spine, classifies each page, and returns
  structured quarantine or reconcile decisions. Uses the Mike Hall voice actor
  definition and Write Good principles throughout.
---

# TMI, PII, PHI & *ism Auditor

Use this skill to audit every public page on `just3ws.com` before a release or
on demand. It pairs with `public-surface-auditor` (security/provenance) and
`prose-humanity-auditor` (readability/voice). This skill focuses on the
**personal boundary** and **discrimination-vector** risks that the other two
skills deliberately defer.

Read `docs/voice-actor.md` before writing any rewrite suggestions. Every
recommendation must preserve the author's voice.

---

## Threat model: what this skill guards

### 1. PII (Personally Identifiable Information)
Direct identifiers that could locate, contact, or uniquely identify Mike or
anyone named in the content.

| Signal | Examples | Severity |
|--------|----------|----------|
| Home address or named suburb as a filter signal | street, city + state, ZIP | High |
| Personal phone or personal email | non-public contact channels | High |
| Family member names with relational context | "my wife Sarah", "son Jake" | Medium |
| Financial account details | card numbers, account IDs | High |
| Government IDs | SSN, DL, passport | Critical |

### 2. PHI (Protected Health Information)
Health or disability details shared in a way that could affect employment,
insurance, or public perception.

| Signal | Examples | Severity |
|--------|----------|----------|
| Named diagnoses | ADHD, autism, AuDHD, depression | Medium-High |
| Medication references | named prescriptions | High |
| Treatment history | therapy, hospitalization | High |
| Disability accommodation requests | public site context | Medium |

PHI rule: the author's own lived experience is theirs to share. The question
is whether the *specific detail* adds value to the *specific page's audience*.
A personal essay may carry it; a resume surface or hiring page should not.

### 3. TMI (Too Much Information / Oversharing)
True personal detail that does not serve the audience of that page and
increases exposure without adding meaning.

| Signal | Examples | Severity |
|--------|----------|----------|
| Relationship status with context | "when I was divorced", "my ex" | Low-Medium |
| Financial distress signals | exact debt figures, "unemployed" framing | Medium |
| Political or religious opinion beyond the author's public record | partisan commentary | Medium |
| Emotional vulnerability as headline copy | grief, burnout framing on a hiring surface | Medium |
| Family life detail beyond general reference | parenting details, schooling choices | Low |

TMI is **not automatically an infraction**. It is a calibration question:
does this detail serve the audience of this specific page?

### 4. *ism Guards (Discrimination Vectors)
Content that signals protected-class characteristics to an audience that
includes employers, clients, or institutional gatekeepers.

| Guard | Signals to audit | Why it matters |
|-------|-----------------|----------------|
| **Ageism** | Graduation years on hiring pages, "X years of experience" totals, decade-specific cultural references as identity markers, early career dates foregrounded | Enables employers to filter by inferred age |
| **Ableism** | Named conditions on hiring surfaces, framing disability as a barrier or as a superpower ("my ADHD lets me..."), cognitive capacity language | Creates bias surface |
| **Classism** | Socioeconomic background signals, college selectivity as identity, self-deprecating class origin on hiring pages | Unnecessary exposure |
| **Familism** | Parental status, caregiver obligations, family configuration | Creates bias surface for employment decisions |
| **Neurotypicality bias** | Apologies for communication style, over-explaining thinking patterns | Signals difference under pressure |

---

## Audit workflow

### Step 1: Build and extract the sitemap spine
```bash
bundle exec jekyll build 2>/dev/null
ruby bin/tmi_audit_sitemap.rb --dry-run
```

### Step 2: Classify each URL by page type
Page types and their thresholds:

| Type | Ageism | PHI | PII | TMI |
|------|--------|-----|-----|-----|
| **Hiring surface** (`/resume/`, `/resumes/`, `/exports/`, `/history/`) | Zero tolerance | Zero tolerance | Zero tolerance | Strict |
| **Blog / personal archive** (`/2006/`-`/2015/`) | Archive-tolerant | Author-consent | Author-consent | Lenient |
| **Oral history / interview** (`/interviews/`) | Archive-tolerant | Third-party consent required | Third-party consent required | Lenient |
| **Portfolio / case studies** | Strict | Strict | Strict | Strict |
| **About / contact / now** | Moderate | Moderate | Contact-route OK | Moderate |

### Step 3: Return structured decisions per page

For each flagged page return:

```yaml
url: https://www.just3ws.com/...
page_type: blog|interview|hiring|portfolio|about
findings:
  - guard: ageism|ableism|tmi|pii|phi|classism|familism
    line: "quoted excerpt (max 80 chars)"
    severity: low|medium|high|critical
    recommendation: quarantine|rewrite|generalize|hold|verify
    suggested_rewrite: "optional — only when the fix is mechanical"
decision: quarantine|reconcile|pass
rationale: "one sentence"
```

### Step 4: Apply decisions
- **quarantine**: Add `sitemap: false` + `robots: noindex,nofollow` to
  frontmatter, or move page to `_drafts/` until reconciled.
- **reconcile**: Apply the suggested rewrite in source, verify with
  `bundle exec rake test`.
- **generalize**: Remove the specific detail; preserve the lesson or arc.
- **hold**: Flag for author review; do not change automatically.
- **pass**: No action.

---

## Decision vocabulary (aligned with public-surface-auditor)

- **Actual risk**: credential, contact route, PHI on a hiring surface,
  third-party health/family detail without consent, discrimination vector on a
  page reaching employers.
- **TMI**: true but unnecessary personal detail. Shorten or leave it out of
  promotion and hiring surfaces. Do not delete archive evidence.
- **Historical signal**: dates, events, tools, and old writing that explain
  provenance. They may stay in the archive even when omitted from resume
  or homepage.
- **Connection barrier**: missing contact route or broken path to correction.
  Do not remove the sole contact mechanism.

---

## *ism guard: ageism detail

Ageism is the highest-frequency risk on a long-tenured technical portfolio.

**Signals to flag on hiring surfaces:**
- Graduation year or first job date in a prominent position
- "X+ years of experience" in the summary or headline
- Technology references that function as generational markers
  ("I remember when IE6...", "since the .com boom") on resume or about pages
- Total-career-year claims in bios or summaries

**Safe in the archive:**
- Dated blog posts: the date is provenance, not an age claim
- Interviews referencing historical events: the event is the content

**Suggested rewrites:**
- Remove graduation year from resume/about pages
- Replace "20+ years" with scope framing: "across enterprise, startup, and
  consultancy contexts"
- Replace decade-specific cultural references on hiring surfaces with
  outcome-focused equivalents

---

## Write Good principles (applied to all rewrites)

Every rewrite suggestion in this audit must follow the voice in
`docs/voice-actor.md` and these principles:

1. Short sentences. Under 20 words. Split anything longer.
2. Active voice. Subject did action.
3. No em dashes. Use commas, colons, or new sentences.
4. No AI jargon. No "delve", "leverage" (when "use" works), "synergistic".
5. Lead with the concrete outcome or fact.
6. Preserve the author's authentic, direct, curious technical voice.
7. Archive passages get the benefit of the doubt. Hiring surfaces do not.
