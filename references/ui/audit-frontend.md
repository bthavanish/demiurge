# Audit Frontend Mode

Audit frontend, UI, and UX code. Generates a report following impeccable's audit approach but adapted for all frontend frameworks.

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

4. **Generate report.** Use the report template.

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

## Findings

### P0 - Critical
[accessibility blockers, security issues]

### P1 - High
[design system violations, major a11y issues]

### P2 - Medium
[anti-patterns, performance issues]

### P3 - Low
[style inconsistencies, minor improvements]

## Recommendations

[ranked list of highest-impact fixes with specific commands/files]
```

## Rules

- Score each category 0-10 based on compliance.
- Tag findings with P0-P3 severity.
- Provide specific file:line references.
- Include concrete fixes, not just problem descriptions.
- If DESIGN.md exists, every deviation from it is at least P2.
