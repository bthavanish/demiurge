# demiurge

All-in-one AI skill for building, auditing, critiquing, and hardening code. Combines senior-dev laziness, token-efficient output, human-like writing, frontend design critique, and strict coding standards into one unified workflow.

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

### Default (iamstupid)

No mode needed. Just type what you want in natural language:

```bash
/demiurge
/demiurge iamstupid
/demiurge fix the security issues in my api
/demiurge clean up this frontend code
/demiurge make a settings page
/demiurge what can I delete from this repo
```

Parses intent, routes to the right modes, presents findings, asks which fixes to apply.

### Build Modes

| Mode | Command | Description |
|------|---------|-------------|
| `make` | `/demiurge make [feature]` | Builds on user instructions using ponytail ladder + coding standards. |
| `design-material` | `/demiurge design-material [target]` | **Only when explicitly requested.** Material Design 3 builder. |

### Evaluate Modes

| Mode | Command | Description |
|------|---------|-------------|
| `audit` | `/demiurge audit [target]` | Full codebase audit. Security, logic, dead code, style, architecture. |
| `audit-frontend` | `/demiurge audit-frontend [target]` | Frontend/UI/UX audit. Design tokens, a11y, responsive, anti-patterns. |
| `audit-backend` | `/demiurge audit-backend [target]` | Backend/logic/security audit. Injection, auth, error handling, type safety. |
| `critique` | `/demiurge critique [target]` | UX design review. Nielsen heuristics (/40), cognitive load, personas. |
| `review` | `/demiurge review [target]` | One-line code review. Severity-tagged: bug, risk, nit, q. |

### Refine Modes

| Mode | Command | Description |
|------|---------|-------------|
| `secure-code` | `/demiurge secure-code [target]` | Fixes bugs, vulnerabilities, logic errors, dead code directly. |
| `humanize` | `/demiurge humanize [target]` | Detects AI patterns in code and rewrites to sound human. |
| `polish` | `/demiurge polish [target]` | Final quality pass. Typography, spacing, color, motion, copy. |
| `harden` | `/demiurge harden [target]` | Production-readiness. Error handling, i18n, edge cases. |
| `bolder` | `/demiurge bolder [target]` | Amplifies bland designs. More decisive and committed. |
| `quieter` | `/demiurge quieter [target]` | Tones down aggressive or overstimulating designs. |

### Manage Modes

| Mode | Command | Description |
|------|---------|-------------|
| `debt` | `/demiurge debt [target]` | Harvests `ponytail:` comment markers into a debt ledger. |
| `compress` | `/demiurge compress [filepath]` | Compresses natural language files to save tokens. |
| `commit` | `/demiurge commit` | Generates terse conventional commit messages. |

## How iamstupid Works

When you call `/demiurge` or `/demiurge iamstupid [prompt]`, it:

1. **Parses your words** for intent signals (security, frontend, backend, quality, build, fix, etc.)
2. **Routes to the right modes** based on detected intent
3. **Runs the audit/check** and generates a structured report
4. **Asks which fixes to apply** before making any changes

Example flow:

```
You: /demiurge iamstupid fix the auth in my api

Me: [Parses: security + auth + api -> audit-backend]
    [Scans src/api/ for security issues]
    [Presents P0-P3 findings]
    [Asks: "Which would you like me to fix?"]

You: fix the JWT and CORS issues

Me: [Applies fixes with secure-code]
    [Reports what was done]
```

When called with no arguments, it runs a full codebase audit and asks which findings to address.

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
- **Always ask before fixing.** Never auto-fix without presenting findings and getting user confirmation.

## File Structure

```
demiurge/
├── SKILL.md                        # Main skill definition
├── README.md                       # This file
├── LICENSE                         # MIT
├── .claude-plugin/
│   └── plugin.json                 # Claude Code plugin manifest
├── references/
│   ├── iamstupid.md                # Auto-routing from natural language
│   ├── human-committing.md         # Human commit flow style
│   ├── make.md                     # Build new features
│   ├── audit.md                    # Full codebase audit
│   ├── audit-frontend.md           # Frontend/UI/UX audit
│   ├── audit-backend.md            # Backend/logic/security audit
│   ├── critique.md                 # UX design review
│   ├── review.md                   # One-line code review
│   ├── design-material.md          # Material Design 3 (explicit only)
│   ├── secure-code.md              # Fix bugs, vulns, dead code
│   ├── humanize.md                 # Remove AI slop
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
    └── audit/                      # TypeScript audit scripts
```

## License

MIT. Copyright 2026 Thavanish brijesh.
