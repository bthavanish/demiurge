# Audit Frontend Mode

Audit frontend, UI, and UX code. Generates a comprehensive report covering design system compliance, accessibility, UX heuristics, and anti-pattern detection.

## Scope

Audit only files that are part of the UI layer:
- HTML, JSX, TSX, Vue, Svelte templates
- CSS, SCSS, LESS, Tailwind classes
- UI component files (React, Vue, Svelte, Angular components)
- Style configuration (tailwind.config, theme files, design tokens)
- Frontend entry points and routing

Skip backend logic, API routes, database queries, and utility code that does not touch the UI.

## Workflow

1. **Discover frontend files.** Glob for UI-related files by extension and framework patterns.
2. **Load design context.** Check for DESIGN.md, tailwind.config, theme files, CSS custom properties, design tokens.
3. **Run checks.** Apply the checks below to every frontend file.
4. **Score UX heuristics.** Evaluate Nielsen's 10 heuristics (see below).
5. **Run persona testing.** Walk through primary actions as 2-3 personas.
6. **Generate report.** Use the report template.

## Checks

### Design System Compliance
- Hard-coded colors (should use design tokens or CSS custom properties)
- Hard-coded spacing values (should use spacing scale)
- Inconsistent typography (font sizes, weights, line heights not from type scale)
- Missing or inconsistent border-radius usage
- Inconsistent elevation/shadow usage
- Violations of DESIGN.md if present

### Accessibility (a11y)
- Missing alt text on images
- Missing ARIA labels on interactive elements
- Insufficient color contrast (< 4.5:1 for body text, < 3:1 for large text)
- Missing keyboard navigation support
- Missing focus indicators
- Missing form labels
- Missing skip navigation links
- Incorrect heading hierarchy (skipped levels)
- Missing role attributes where needed
- Interactive elements without accessible names

### Responsive Behavior
- Hard-coded pixel widths that break on mobile
- Missing responsive breakpoints
- Content overflow at narrow viewports
- Touch targets smaller than 44x44px
- Missing viewport meta tag
- Horizontal scroll on mobile

### Anti-Patterns (AI Slop Detection)
- Side-stripe borders (border-left/right > 1px as colored accent)
- Gradient text (background-clip: text with gradient)
- Glassmorphism as default (decorative blurs)
- Hero-metric template (big number, small label, gradient accent)
- Identical card grids (icon + heading + text repeated)
- Tiny uppercase tracked eyebrows on every section
- Numbered section markers as default scaffolding (01/02/03)
- Text overflowing containers
- Cream/sand/beige body background (the saturated AI default)
- Gray text on colored backgrounds
- Nested cards, bounce easing

### Performance
- Unoptimized images (missing lazy loading, missing srcset)
- Render-blocking resources
- Excessive re-renders (React: missing memo, unstable references)
- Large bundle imports (importing entire libraries)
- Missing code splitting boundaries
- Layout shift (CLS) from unsized elements

### Interaction
- Dropdowns in overflow:hidden containers (use dialog/popover/portal)
- Missing loading states
- Missing error states
- Missing empty states
- Uncontrolled form inputs

## UX Heuristics Scoring

Score each of Nielsen's 10 heuristics 0-4:

| # | Heuristic | What to check |
|---|-----------|--------------|
| 1 | Visibility of System Status | Loading indicators, confirmations, progress, location |
| 2 | Match System/Real World | Familiar terminology, logical order, recognizable icons |
| 3 | User Control and Freedom | Undo/redo, cancel, back, escape from traps |
| 4 | Consistency and Standards | Consistent terminology, same actions = same results |
| 5 | Error Prevention | Confirmation before destructive actions, constraints, smart defaults |
| 6 | Recognition Rather Than Recall | Visible options, contextual help, autocomplete, labels on icons |
| 7 | Flexibility and Efficiency | Keyboard shortcuts, bulk actions, power user features |
| 8 | Aesthetic and Minimalist Design | Only necessary info, clear hierarchy, no clutter |
| 9 | Error Recovery | Plain language errors, specific identification, actionable suggestions |
| 10 | Help and Documentation | Searchable, task-focused, concise, easy to access |

**Total:** /40. 36-40 excellent, 28-35 good, 20-27 acceptable, 12-19 poor, 0-11 critical.

## Cognitive Load Assessment

8-item checklist. Count failures. 0-1 = low, 2-3 = moderate, 4+ = high.
- Single focus per screen
- Chunking of information
- Grouping related items
- Visual hierarchy引导注意力
- One thing at a time
- Minimal choices at decision points
- Working memory limits (<=4 options manageable, 5-7 pushing it, 8+ overloaded)
- Progressive disclosure

## Persona Testing

Select 2-3 relevant personas:

- **Alex (Power User)**: Expert, expects efficiency, skips onboarding, finds shortcuts.
- **Jordan (First-Timer)**: Never used this, needs guidance, abandons rather than figures out.
- **Sam (Accessibility-Dependent)**: Screen reader, keyboard-only, needs ARIA and contrast.
- **Riley (Stress Tester)**: Tests edge cases, empty states, unexpected input.
- **Casey (Mobile User)**: One-handed, interrupted, slow connection, thumb zone.

Walk through the primary user action as each persona. Report specific red flags with exact elements and interactions.

## Severity Levels

- **P0 Blocking**: Prevents task completion. Fix immediately.
- **P1 Major**: Significant difficulty or WCAG AA violation. Fix before release.
- **P2 Minor**: Annoyance, workaround exists. Fix in next pass.
- **P3 Polish**: Nice-to-fix, no real user impact. Fix if time permits.

## Report Template

```markdown
# Frontend Audit Report

**Date:** [date]
**Files scanned:** [count]
**Framework:** [React/Vue/Svelte/Plain HTML]
**Design system:** [present/missing]

## Summary

| Category | Score | Issues |
|----------|-------|--------|
| Design System | [n]/10 | [count] |
| Accessibility | [n]/10 | [count] |
| Responsive | [n]/10 | [count] |
| Anti-Patterns | [n]/10 | [count] |
| Performance | [n]/10 | [count] |
| Interaction | [n]/10 | [count] |
| **Total** | **[n]/60** | **[total]** |

## UX Heuristic Scores

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | ? | ... |
| ... | ... | ... | ... |
| **Total** | | **??/40** | |

## Anti-Patterns Verdict

Does this look AI-generated? List specific tells.

## What's Working

2-3 things done well. Be specific about why.

## Priority Issues

For each:
- **[P?] What**: Name the problem
- **Why it matters**: How this hurts users
- **Fix**: What to do about it

## Persona Red Flags

[per-persona findings]

## Minor Observations

## Questions to Consider
```

## Rules

- Score each category 0-10 based on compliance.
- Tag findings with P0-P3 severity.
- Provide specific file:line references.
- Include concrete fixes, not just problem descriptions.
- If DESIGN.md exists, every deviation from it is at least P2.
- Be direct. Vague feedback wastes time.
- Be specific. "The submit button," not "some elements."
- Say what's wrong AND why it matters.
- Prioritize ruthlessly. If everything is important, nothing is.
- Don't soften criticism.
