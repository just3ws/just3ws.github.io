# just3ws Refresh Implementation Contract

## File Ownership

| Concern | Preferred location |
| --- | --- |
| public canonical content | `_data/` |
| page composition | page HTML or `_layouts/` |
| shared fragments | `_includes/` |
| design tokens | `_sass/_p_variables.scss` or the owning theme module |
| shared layout rules | `_sass/_p_base_layout.scss` |
| page and archive patterns | `_sass/_p_main.scss` or the closest existing module |
| browser behavior | `assets/js/` or the owning include when already inline |
| rendered expectations | `tests/layout.spec.js` |

Do not edit generated `_site/`, generated exports, or derived resume output.

## Preservation Checklist

- Keep route slugs, canonical URLs, anchor IDs, and primary nav labels stable unless explicitly authorized.
- Keep Jekyll SEO tags, JSON-LD, sitemap behavior, and social metadata intact.
- Keep GoatCounter selectors and outbound/download semantics intact.
- Preserve the skip link, semantic landmarks, heading order, `aria-current`, keyboard navigation, focus visibility, and meaningful image alternatives.
- Keep Public Canon separate from Private Context. New public assets need clear provenance and approval.
- Preserve theme parity when touching a component that renders in both modern and Kanagawa themes.

## Design Engineering Rules

- Derive selectors and file placement from two local analogs where possible.
- Prefer semantic tokens over one-off literals.
- Keep a consistent accent and radius system within the changed surface.
- Avoid repeating the same card or split-layout family for every section.
- Use `max-width` and readable line lengths for prose; allow dense metadata surfaces to remain dense.
- Declare each multi-column mobile fallback explicitly.
- Give interactive elements hover, active, and visible focus states.
- For motion, prefer `transform` and `opacity`, avoid forced scroll hijacking, and honor `prefers-reduced-motion`.
- Reserve image space with dimensions to avoid layout shift.

## Validation Order

1. Run the most focused test or inspect the target build output.
2. Run `bundle exec jekyll build`.
3. Run `./bin/pipeline smoke` for changed layout, navigation, or interaction behavior.
4. Run `./bin/pipeline ci` when the change crosses shared layout, generator, canonical data, or metadata boundaries.
5. Capture desktop and 375px mobile screenshots for visual changes.

Never report a command as passing unless its exit status was observed.
