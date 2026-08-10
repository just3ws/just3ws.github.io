# just3ws Refresh Review Gate

## Evidence Required

- approved Refresh Brief
- diff limited to the authorized slice
- current desktop and 375px mobile render evidence
- observed build and smoke-test results
- explicit disclosure when browser or screenshot evidence is unavailable

## Visual Gate

- The page job and first visual hierarchy are understandable without reading every block.
- The result matches the declared design read and target dial movement.
- Typography has deliberate scale, line length, wrapping, and weight hierarchy.
- Palette, neutral temperature, accent use, radii, borders, and shadows follow a coherent rule.
- Cards communicate real grouping; archive lists are not boxed solely for decoration.
- Repeated sections do not collapse into a generic equal-card or endless zigzag template.
- Existing assets are used honestly and at suitable aspect ratios.
- Desktop navigation stays legible; mobile composition has explicit collapse behavior and no horizontal overflow.

## Interaction and Accessibility Gate

- Skip link and semantic landmarks remain usable.
- Keyboard order is logical and changed controls show visible focus.
- Hover, active, current, expanded, loading, empty, and error states exist where the changed surface needs them.
- Text and control contrast meet WCAG AA.
- Motion is motivated, smooth, and disabled or simplified for `prefers-reduced-motion`.
- Images have dimensions and correct alt behavior; decorative images use empty alt text only when truly decorative.

## Archive and Platform Gate

- No route, canonical URL, primary nav label, anchor ID, metadata, JSON-LD, sitemap behavior, or analytics hook changed without authorization.
- No private or unapproved material crossed into Public Canon.
- Provenance and confidence language remain accurate.
- Both modern and Kanagawa themes remain coherent for shared components.
- Jekyll build and relevant pipeline checks pass.

## Anti-Template Review

Flag only when supported by rendered evidence:

- generic centered hero followed by equal cards
- decorative labels, pills, badges, gradients, or dots repeated without meaning
- one layout family reused until the page feels generated
- placeholder copy, fabricated metrics, fake product UI, or generic stock imagery
- motion added for spectacle rather than hierarchy, feedback, or narrative
- global aesthetic rules applied to archive surfaces whose job requires density

## Severity

- `blocker`: public safety, broken build, inaccessible primary path, lost route, or corrupt canonical output
- `major`: design brief failure, responsive breakage, SEO/analytics regression, or clear accessibility failure
- `minor`: local inconsistency or polish issue that does not block use
