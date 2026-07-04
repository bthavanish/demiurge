# demiurge

All-in-one AI skill for building, auditing, critiquing, and hardening code. Combines senior-dev laziness, token-efficient output, human-like writing, frontend design critique, Material Design 3, and strict coding standards into one unified workflow.

## Install

### Claude Code

```bash
/plugin marketplace add thavanish-brijesh/demiurge
```

Then:

```bash
/plugin install demiurge@demiurge
```

### Manual

Clone this repo and copy `SKILL.md` and `references/` into your skill directory.

## Usage

```
/demiurge [mode] [target]
```

### Build Modes

| Mode | Description |
|------|-------------|
| `make` | **Default.** Builds on user instructions using ponytail ladder + coding standards. |
| `design-material` | Builds UI using Material Design 3 guidelines. Token-driven, platform-aware. |

### Evaluate Modes

| Mode | Description |
|------|-------------|
| `audit` | Audits every file in the codebase. Full report: security, logic, dead code, style, architecture. |
| `audit-frontend` | Audits frontend/UI/UX code. Design tokens, accessibility, responsive, anti-patterns. |
| `audit-backend` | Audits backend/logic code. Security, error handling, type safety, logic correctness. |
| `critique` | UX design review. Nielsen heuristics scoring (/40), cognitive load, persona testing. |
| `review` | One-line code review. Severity-tagged findings: bug, risk, nit, q. |

### Refine Modes

| Mode | Description |
|------|-------------|
| `secure-code` | Fixes bugs, vulnerabilities, logic errors, and dead code directly. |
| `humanize` | Detects AI-generated patterns in code and rewrites them to sound human. |
| `polish` | Final quality pass. Typography, spacing, color, motion, copy, edge cases. |
| `harden` | Production-readiness: error handling, i18n, text overflow, edge cases. |
| `bolder` | Amplifies safe or bland designs. More decisive and committed. |
| `quieter` | Tones down aggressive or overstimulating designs. |

### Manage Modes

| Mode | Description |
|------|-------------|
| `debt` | Harvests `ponytail:` comment markers into a tracked debt ledger. |
| `compress` | Compresses natural language files into terse format to save tokens. |
| `commit` | Generates terse conventional commit messages. |

### Examples

```bash
/demiurge make add user authentication with JWT
/demiurge audit src/
/demiurge audit-frontend src/components/
/demiurge audit-backend src/api/
/demiurge critique src/pages/dashboard.tsx
/demiurge review src/auth.ts
/demiurge design-material build a settings page
/demiurge secure-code src/
/demiurge humanize src/
/demiurge polish src/components/
/demiurge harden src/api/
/demiurge bolder src/landing.tsx
/demiurge quieter src/dashboard.tsx
/demiurge debt
/demiurge compress CLAUDE.md
/demiurge commit
```

## What Each Mode Does

### make (default)

Climbs the ponytail ladder before writing code. Ships the minimum code that works. Code first, then at most 3 lines explaining what was skipped.

### audit

Scans every source file for security vulnerabilities, logic errors, dead code, style violations, and architecture issues. Generates a P0-P3 severity report.

### audit-frontend

Checks design system compliance, accessibility (WCAG AA), responsive behavior, AI anti-patterns, and performance. Scores each dimension 0-10.

### audit-backend

Security-oriented audit for backend code. Checks injection, auth, crypto, error handling, type safety, logic correctness, and performance.

### critique

UX design review with Nielsen's 10 heuristics scoring (/40), cognitive load assessment (8-item checklist), and persona-based testing (5 personas). Generates a structured critique report with priority issues.

### review

One-line code review comments. Severity-tagged: bug, risk, nit, q. If code looks good, says LGTM and stops.

### design-material

Builds MD3-compliant UI with correct design tokens, component-first approach, platform awareness (Compose, Flutter, Web), dark theme, and responsive navigation.

### secure-code

Fixes everything directly: secrets to env vars, parameterized queries, input validation, dead code removal, magic numbers to constants, error handling.

### humanize

Detects 10 code-level AI patterns (unnecessary abstractions, boilerplate, over-documentation, performative naming, etc.) and 33 comment/documentation patterns. Rewrites them all.

### polish

Systematic final pass across visual alignment, typography, color contrast, interaction states, content, forms, edge cases, responsive behavior, performance, and code quality.

### harden

Production-readiness: error handling, i18n, text overflow, edge cases, security headers, rate limiting, graceful degradation.

### bolder

Amplifies bland designs by pushing one focal point using color, typography, spacing, motion, and composition within the existing design system.

### quieter

Reduces visual noise by desaturating secondary colors, increasing whitespace, slowing animations, and removing decorative elements.

### debt

Scans for `ponytail:` comment markers and generates a debt ledger with ceiling and upgrade path for each shortcut.

### compress

Compresses natural language files (.md, .txt) into terse format. Preserves code blocks, URLs, file paths, commands, and technical terms exactly.

### commit

Generates terse conventional commit messages. Subject: <=50 chars, imperative, lowercase after type. Body only when "why" isn't obvious.

## Base Rules (all modes)

Every mode applies these non-negotiable rules:

- **Ponytail ladder** -- simplest solution first. YAGNI. Reuse before building.
- **Caveman output** -- terse output, full accuracy. Code blocks preserved verbatim.
- **Humanizer** -- no AI slop in code or prose. No em dashes, no rule-of-three, no AI vocabulary.
- **Coding standards** -- KISS, SRP, descriptive names, no magic numbers, immutability, portable, no hallucinations.
- **Comment standards** -- why not what, no dead code, no metadata, ponytail markers for shortcuts.
- **DESIGN.md enforcement** -- follow the design system if one exists.
- **Modularity** -- small, cohesive, loosely coupled functions. Dependencies flow one direction.
- **No hardcoding** -- env vars, config files, constants, parameters.

## File Structure

```
demiurge/
├── SKILL.md                        # Main skill definition
├── README.md                       # This file
├── LICENSE                         # MIT
├── .claude-plugin/
│   └── plugin.json                 # Claude Code plugin manifest
├── references/
│   ├── make.md                     # Build new features
│   ├── audit.md                    # Full codebase audit
│   ├── audit-frontend.md           # Frontend/UI/UX audit
│   ├── audit-backend.md            # Backend/logic/security audit
│   ├── critique.md                 # UX design review
│   ├── review.md                   # One-line code review
│   ├── design-material.md          # Material Design 3 builder
│   ├── secure-code.md              # Fix bugs, vulns, dead code
│   ├── humanize.md                 # Remove AI slop from code
│   ├── polish.md                   # Final quality pass
│   ├── harden.md                   # Production-readiness
│   ├── bolder.md                   # Amplify bland designs
│   ├── quieter.md                  # Tone down aggressive designs
│   ├── debt.md                     # Track ponytail shortcuts
│   ├── compress.md                 # Compress memory files
│   ├── coding-standards.md         # Full coding best practices
│   ├── comment-standards.md        # Full comment guidelines
│   ├── design-defaults.md          # DESIGN.md enforcement
│   ├── platform-native.md          # Platform-native alternatives
│   └── structural-slop.md          # Review for agent-style slop
└── scripts/
    ├── compress/                   # Caveman compression scripts
    │   ├── __main__.py
    │   ├── cli.py
    │   ├── compress.py
    │   ├── detect.py
    │   ├── validate.py
    │   └── benchmark.py
    └── audit/                      # TypeScript audit scripts
        ├── audit-typescript-repo.sh
        ├── audit-typescript-dead-code.sh
        ├── audit-typescript-duplicate-code.sh
        ├── audit-typescript-architecture.sh
        └── lib/
            └── common.sh
```

## License

MIT. Copyright 2026 Thavanish brijesh.
