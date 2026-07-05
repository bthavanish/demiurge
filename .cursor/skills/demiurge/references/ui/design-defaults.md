# DESIGN.md Enforcement

When a `DESIGN.md` file exists in the project root or nearest parent directory, read it and enforce its design system strictly. This reference explains how.

## When to Look

- On project first load (make, audit, any mode).
- Do not always search for it. Only read it if it exists in the project root or nearest parent.
- If found, treat it as the authoritative design system for all UI work.

## What DESIGN.md Typically Contains

- **Design tokens:** colors (hex/OKLCH values, color roles), typography (font families, sizes, weights, line heights), spacing scale, border radii, shadows/elevation.
- **Component patterns:** approved component variants, props, and usage rules.
- **Layout rules:** grid systems, breakpoints, container widths, spacing patterns.
- **Motion guidelines:** animation durations, easing curves, reduced-motion alternatives.
- **Accessibility requirements:** minimum contrast ratios, focus styles, screen reader patterns.
- **Do/Don't examples:** specific patterns to use and patterns to avoid.
- **Anti-patterns:** things explicitly banned in this project.

## How to Enforce

### For Building (make, design-material)

- Use only tokens, colors, fonts, and spacing defined in DESIGN.md.
- Use only approved component patterns.
- Follow layout rules exactly.
- Apply motion guidelines.
- Respect accessibility requirements.
- Never deviate from the design system without the user explicitly asking.

### For Auditing (audit, audit-frontend, audit-backend)

- Check every UI file against DESIGN.md.
- Any deviation from declared tokens is a finding (at least P2).
- Hardcoded colors that should use tokens: P1.
- Inconsistent typography: P2.
- Missing responsive behavior per DESIGN.md breakpoints: P2.
- Anti-patterns listed in DESIGN.md: P1.

### For Securing (secure-code)

- DESIGN.md does not override security requirements.
- If DESIGN.md conflicts with security (e.g., requests inline scripts), flag the conflict and follow security rules.

### For Humanizing (humanize)

- AI slop patterns that conflict with DESIGN.md are always violations.
- If DESIGN.md prescribes a specific pattern, use it even if it resembles an AI pattern -- the project's design system takes precedence over general anti-pattern rules.

## Enforcement Rules

1. **Token-driven.** Never hardcode a value that DESIGN.md provides as a token.
2. **Component-faithful.** Use the component variants DESIGN.md specifies. Do not invent new variants.
3. **Layout-compliant.** Follow the grid, breakpoint, and spacing rules.
4. **Motion-aligned.** Use the approved durations and easing curves.
5. **Accessible.** Meet or exceed the accessibility requirements.
6. **Consistent.** When DESIGN.md is ambiguous, choose the option most consistent with its existing examples.
7. **Non-negotiable.** The design system is not a suggestion. It is a contract.
