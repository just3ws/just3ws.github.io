---
name: editorial-fact-checker
aliases:
  - authenticity-auditor
  - fact-checker
description: Audits and verifies technical claims, historical dates, conference venues, software names, and audio/DSP contracts against ground truth across video scripts, dossiers, and site documentation.
---

# Editorial Fact-Checker & Authenticity Auditor Skill

Use this skill when auditing video scripts, episode dossiers, presentation slides, YouTube metadata, and technical articles for historical accuracy, technical ground truth, and unvarnished authenticity.

---

## 🎯 Core Responsibilities

1. **Ground-Truth Historical Verification**:
   - Verify all conference dates, venue names, user group histories, and interviewee names against primary source archives:
     * SCNA (Software Craftsmanship North America): Chicago, 2009 to 2016.
     * SCMC (Software Craftsmanship McHenry County): Mike Hall co-founded SCMC (#106) with Ryan Gerry and Jim Suchy (following the October 2009 SCNA table meeting with Ryan Gerry that launched CDG in McHenry County libraries, Panera Bread, and Duke's Alehouse), hosted at Follett Software Company in McHenry, IL. Ryan Gerry continued running SCMC after Mike stepped away after the two-year anniversary.
     * Chicago Code Camp: Grassroots zero-dollar-budget developer conference (2009 to 2013) at College of Lake County in Grayslake, IL, co-organized by Mike Hall with a custom blind-review speaker engine.
     * Chicago Alt.NET: Grassroots enterprise .NET community formed in 2007-2008, inspired by the 2007 Austin Alt.NET conference.
     * Obtiva: Chicago-area software craftsmanship consultancy founded by Dave Hoover (2005 to 2011; acquired by Groupon in 2011).
   - Use the CareerOS datalake to query exact historical transcripts and dates:
     `ruby bin/query_career_datalake.rb "Search term"`

2. **De-Melodramatization & Plain Language Audit**:
   - Audit all text for theatrical framing, melodrama, or academic inflation:
     * Use **"The Chicago Workshop"** for Movement 1 (never theatrical battle/forge metaphors).
     * Reject "Escaping Corporate Monoliths" in favor of **"Practical Autonomy in Enterprise .NET"**.
     * Reject "Forensic Audio Experiment" in favor of **"Northern Illinois Field Dispatch"**.
     * Reject "Oral History Rewatch" in favor of **"UGtastic Technical Rewatch Series"**.
   - Check that claims reflect practitioner reality, not mythmaking. Alt.NET was not a rebellion against Microsoft; it was enterprise developers adopting open tools (NUnit, StructureMap, NHibernate) and agile testing.

3. **Technical & Acoustic Fact-Checking**:
   - Verify hardware, electrical, and audio engineering claims:
     * 345,000-volt (345kV) transmission line electromagnetic induction and corona discharge.
     * 60 Hz fundamental mains hum and odd harmonics (180 Hz, 300 Hz, 420 Hz).
     * Smartphone secondary top microphone operating as an unshielded inductive antenna loop picking up 65x noise compared to primary speech mic.
     * 40-millisecond deterministic scipy and bash filter pipeline running locally on Apple Silicon.
   - Guard against LLM hallucinations: verify calculations, duration ratios, and DSP math before accepting script assertions.

4. **Pre-Broadcast Publishing Gate Checklist**:
   - *Title Budget*: Strictly <= 100 characters for YouTube API compatibility, optimal <= 70 characters for mobile displays.
   - *Description Budget*: Strictly <= 5000 characters with required canonical links (`just3ws.com/series/the-sound-above/`, `patreon.com/whoistechcmty`).
   - *Zero Em Dashes*: Zero `\u2014`, zero ` -- `, and zero ` - `.
   - *Chapter & Caption Parity*: Verify WebVTT transcript file exists and timecodes align with ground-truth audio.

---

## 🛠️ Verification Commands

```sh
# Query historical corpus and interview transcripts
ruby bin/query_career_datalake.rb "Sergio Pereira"
ruby bin/query_career_datalake.rb "Alt.NET"

# Audit repository hygiene and em-dash compliance
bin/pipeline validate fast

# Verify episode dossiers and character budgets
bin/pipeline media stage <N>
bin/pipeline media stage --all

# Audit YouTube metadata and best practices
bin/pipeline media youtube audit
```
