---
layout: minimal
title: Public Artifact Curation Policy
description: How personal history and archival material are curated for public publication.
permalink: /docs/public-artifact-curation-policy/
---

# Public Artifact Curation Policy

This policy governs how personal history, technical work, interviews, and
archival material move from private working notes into public publication.

The goal is not to make the record sterile. The goal is to preserve meaning
while reducing unnecessary exposure, protecting other people, and keeping the
evidence boundary clear.

## The four publication questions

Before publishing a detail, ask:

1. Does this detail explain the lesson or only add intensity?
2. Is the detail about me, or does it expose someone else?
3. Could a reader identify a person, medical event, household, or private workplace from the combination of details?
4. Would I still choose this wording after the emotional urgency has passed?

## Curation levels

### Publish

Use for public work, public dates, public recordings, published software, and
personal observations that do not expose another person.

### Contextualize

Use for personal material that explains a public lesson. Keep the lesson and
generalize exact medical, household, financial, or family details.

### Hold for review

Use when a detail names or could identify another living person, reveals a
private workplace matter, or combines several details into a recognizable
private event.

### Private archive

Use for raw recollection, medical information about another person, intimate
family history, private contact details, and material whose value depends on
exposure rather than understanding.

## Default decisions

- A person's medical information is private by default, including when the person is family.
- Protected health information and other health details require the highest review threshold. Do not publish a person's diagnosis, treatment, admission, recovery details, or care location unless they have explicitly chosen that public disclosure.
- Personally identifiable information includes combinations of ordinary details. A name, date, location, relationship, employer, and event may identify someone together even when none is sensitive alone.
- Children appear only through broad life context unless there is a compelling reason and appropriate consent.
- Other people's names remain public only when their public role is central and the source is already public.
- Exact locations and dates stay only when they establish a historical claim or link to public evidence.
- Workplace lessons remain public-safe. Internal identifiers, customer details, and unresolved disputes do not become public examples by default.
- A public archive can preserve a source without publishing every detail from that source.
- A disclosure note explains the curation. It does not replace the curation.
- Hiring-facing pages lead with current capability, relevant outcomes, and scope.
  They do not need graduation dates, birth dates, total-career-year claims, or
  exact tenure in older roles.
- Historical dates remain appropriate in the archive when they establish the
  provenance or sequence of a public event. The archive is not the same surface
  as a resume.
- Use Staff Software Engineer as the professional identity, rooted in the
  profession of software engineering. Use Principal when describing a target
  posting, a scale-dependent role calibration, or a documented historical
  title.

This policy is an editorial safety standard, not legal advice. When the boundary
is unclear, hold the detail for review and publish the lesson without it.

## Public versions of personal essays

Public essays should lead with the lesson, use the minimum personal context
needed to make that lesson honest, and give the reader a clear way to return to
the technical or historical evidence. The private source can remain fuller than
the public essay.

## Reader-first narrative filter

Before publishing a personal detail, ask whether it helps the reader understand
the work, the decision, or the lesson. If it only increases emotional force,
compress it or leave it in the private archive.

Public narratives should follow this order:

1. State the useful insight.
2. Give the minimum context needed to understand why it mattered.
3. Describe the action, adaptation, or practice that followed.
4. Show what changed or what the reader can carry forward.

Use difficult life circumstances as context, not spectacle. Keep the dignity of
other people intact. Avoid self-diagnosis, speculation about motives, and
dramatic details that make the author the subject when the real subject is the
work or the lesson.

When a passage feels unusually vivid, self-accusing, or performative, pause
before publishing it. A quieter version often carries the history more
faithfully because it leaves room for the reader to see the meaning.

The final test is simple: if the personal detail were removed, would the reader
lose the lesson? If not, it belongs in the private archive or in a shorter,
generalized form.

## Authenticity without transgression

Authenticity does not require maximum disclosure. A public story can be honest,
funny, technically specific, emotionally real, and unmistakably in the
author's voice without publishing another person's private circumstances.

The boundary is not a limit on being interesting. It keeps the story centered
on what the author knows, did, learned, and can responsibly invite the reader
to understand. Specificity belongs where it creates meaning. Restraint belongs
where additional detail would expose someone who did not choose the public
stage.

The publication question is therefore not only "Is this true?" It is also "Is
this mine to tell, and is this the least exposing form that preserves the
meaning?"

## Do not corner the author

A public article should not turn a moment of thinking aloud into a promise,
accusation, confession, diagnosis, or definitive claim. Preserve the useful
observation and remove language that could make the author answer for more than
the evidence supports.

When a sentence could be read as a claim about another person, an employer, a
private event, or the author's certainty, revise it toward one of these forms:

- What I observed
- What I was trying to understand
- What the surviving record supports
- What I would verify before claiming more

This keeps the voice direct and human while leaving room for correction,
context, and the dignity of everyone involved.

The public version should say when personal details have been generalized. It
should not imply that an AI tool verified memories, consent, or private facts.

This approach follows the privacy principle that people should be able to form
reliable expectations about how information is used. It also follows archival
practice that public access and privacy review are separate responsibilities.
See the [NIST Privacy Framework](https://www.nist.gov/privacy-framework/getting-started-0)
and [NARA guidance for sensitive PII in open archival materials](https://www.archives.gov/files/about/policies/nara1607.pdf).

## Review cadence

Review personal-context essays before major sharing, after a significant life
change, and whenever a new archive source adds identifying detail. A published
page can be corrected without erasing the private record that informed it.

## Automated review aid

Run `ruby bin/audit_public_surface.rb` before a substantial publication pass.
Run `ruby bin/audit_public_surface.rb --strict` as the publication gate.
The tool scans only the repository's documented public-content surfaces. It
excludes secrets, environment files, credentials, private handoffs, dependency
trees, caches, and other non-public paths. Reports redact matched values.

The tool separates urgent credential-shaped findings from review candidates such
as contact details, health or family context, workplace details, local paths,
identity language, and uncertain recollections. The normal audit is an
inventory. The strict gate fails until high-risk findings and quarantined
recollections receive a human decision. A finding is an invitation to review,
not proof that a passage is unsafe, and a clean run is not proof that the
public surface contains no risk.

This follows the zdots PHI lesson: filtering is a boundary concern, not a final
cleanup step. PHI and credential patterns belong to the canonical local
scrubber, which runs before material is sent to AI, captured, indexed, or
stored. This site auditor complements that gate by reviewing public artifacts;
it does not replace the local scrubber or authorize moving private source
material into the public corpus.

Use the report to ask: Is this mine to publish? Is it necessary to the lesson?
Can the same meaning survive with less identifying detail? What source supports
the claim? If the answer is unclear, hold the detail and publish the useful
lesson in a generalized form.

### Recollection quarantine

Uncertain recollections are kept in a separate quarantine section of the audit
report. Quarantine does not mean the memory is false. It means the public copy
must not present it as independently verified fact.

Recorded transcript text is handled differently. When a passage is in the
canonical transcript surface and belongs to a linked recording, uncertainty
spoken by the participant is part of the historical record. It is not silently
rewritten into certainty, and it is not treated as the author's recollection.
The audit labels this as recorded uncertainty rather than quarantine. The
recording and timestamp remain the evidence. Privacy review still applies to
sensitive content in the recording.

For each quarantined passage, choose one of three human outcomes:

1. Verify it against a recording, dated artifact, public announcement, or other
   surviving source, then link that evidence.
2. Keep the detail, but write it explicitly as recollection and reduce any
   identifying detail that is not needed for the lesson.
3. Hold it from publication while preserving it in the private working archive.

This is especially important for dates, names, motives, signatures, and claims
about what another person or organization knew. The auditor can identify the
boundary. It cannot establish memory, consent, or truth by itself.

The review process should be safe, slow, and soft. Slow is smooth. Smooth is
fast. A large archive does not need to be resolved in one sitting. Work through
a bounded batch, preserve the source, record the decision, and return later with
more context. A pause is a valid outcome. The purpose of the guard is to create
room for judgment, not to make the author prove their worth under pressure.
