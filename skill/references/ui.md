# UI Reference

Frontend audit, DESIGN.md enforcement, Material Design 3, polish/quality pass.

---

## Frontend Audit

### Scope

HTML/JSX/TSX/Vue/Svelte templates, CSS/SCSS/Tailwind, UI components, style config, design tokens.

### Checks

**Design System Compliance:** hard-coded colors, spacing, typography, border-radius, elevation.

**Accessibility:** alt text, ARIA labels, contrast (4.5:1 body, 3:1 large), keyboard nav, focus indicators, form labels, heading hierarchy.

**Responsive:** hard-coded pixel widths, missing breakpoints, touch targets < 44x44px, horizontal scroll on mobile.

**Anti-Patterns (AI Slop):** side-stripe borders, gradient text, glassmorphism as default, hero-metric template, identical card grids, numbered section markers (01/02/03), cream/sand body background.

**Performance:** missing lazy loading, render-blocking resources, excessive re-renders, large bundle imports.

**Interaction:** dropdowns in overflow:hidden, missing loading/error/empty states, uncontrolled form inputs.

### UX Heuristics (Nielsen's 10)

Score 0-4 each. Total /40. 36-40 excellent, 28-35 good, 20-27 acceptable, <20 poor.

1. Visibility of System Status
2. Match System/Real World
3. User Control and Freedom
4. Consistency and Standards
5. Error Prevention
6. Recognition Rather Than Recall
7. Flexibility and Efficiency
8. Aesthetic and Minimalist Design
9. Error Recovery
10. Help and Documentation

### Severity

- **P0 Blocking**: prevents task completion
- **P1 Major**: significant difficulty or WCAG AA violation
- **P2 Minor**: annoyance, workaround exists
- **P3 Polish**: nice-to-fix

---

## DESIGN.md Enforcement

When `DESIGN.md` exists in project root or nearest parent, read it and enforce strictly.

### What It Contains

Design tokens (colors, typography, spacing, radii, shadows), component patterns, layout rules, motion guidelines, accessibility requirements.

### Enforcement Rules

1. Token-driven. Never hardcode a value that DESIGN.md provides as a token.
2. Component-faithful. Use specified variants. Don't invent new ones.
3. Layout-compliant. Follow grid, breakpoint, spacing rules.
4. Non-negotiable. The design system is a contract, not a suggestion.

### For Auditing

Any deviation from declared tokens is a finding (at least P2). Hardcoded colors = P1. Anti-patterns listed in DESIGN.md = P1.

---

## Material Design 3

Build UI using MD3 (Material You). Component-first, token-driven, platform-aware.

### Platform Decision Tree

| Platform | Library |
|---|---|
| Android | `androidx.compose.material3` |
| Flutter | `useMaterial3: true` |
| Web (vanilla) | `@material/web` + CSS custom properties |
| Web (React/Vue) | CSS custom properties + wrapper components |

### Design Token System

- **Color:** MD3 color roles (primary, secondary, tertiary, error, surface). Dynamic color from wallpaper (API 31+). Dark theme from same seed.
- **Typography:** 15 baseline styles (Display/Headline/Title/Body/Label L/M/S). Never hardcode sizes.
- **Shape:** 10 shape tokens (none to full). Component-to-shape mapping.
- **Elevation:** 5 levels. MD3 uses tonal surface color, not shadows.
- **Motion:** Spring-based physics (Expressive). Reduced motion alternatives required.

### Anti-Patterns

- Hardcoded colors instead of tokens
- MD2 and MD3 mixing
- Missing dark theme support
- Non-responsive layouts

### Window Size Classes

| Class | Width | Columns |
|---|---|---|
| Compact | <600dp | 4 |
| Medium | 600-839dp | 8 |
| Expanded | 840-1199dp | 12 |

---

## Polish Mode

Final quality pass. Catches small details separating good from great.

### Workflow

1. Design system discovery. Note conventions, identify drift.
2. Pre-polish assessment. Is it functionally complete? What's the quality bar?
3. Systematic polish through every dimension.
4. Final verification at multiple viewports.
5. Clean up. Replace custom implementations with design system components.

### Dimensions

**Information Architecture:** progressive disclosure, established user flows, naming matches mental model.

**Visual Alignment:** pixel-perfect grid alignment, consistent spacing, optical alignment.

**Typography:** hierarchy consistent, 45-75 char body line length, `text-wrap: balance` on headings.

**Color/Contrast:** body text >= 4.5:1, large text >= 3:1, placeholder text same requirement.

**Interaction States:** default, hover, focus, active, disabled for every interactive element. Loading/error/empty states.

**Micro-interactions:** smooth transitions, consistent easing, respect `prefers-reduced-motion`.

**Responsive:** works at all breakpoints, touch targets >= 44x44px, no horizontal scroll.

### Amplifying Bland Designs

Use when a design is safe to the point of forgettable. Stay within existing tokens.

Levers: push primary color higher, increase heading size, tighten letter-spacing on display text, add entrance animations, one dominant element.

### Toning Down Aggressive Designs

Reduce visual noise while preserving intent.

Levers: desaturate to 70-85%, reduce font weights (900->600), more whitespace, reduce animation distances (10-20px instead of 40px), reduce element count.
