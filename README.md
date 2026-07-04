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
/demiurge                           # full audit + ask which fixes to apply
/demiurge iamstupid                 # same
/demiurge fix the security issues in my api   # context-gather for auth, fix it
/demiurge clean up this frontend code          # context-gather, humanize it
/demiurge make a settings page                 # build it
/demiurge what can I delete from this repo     # debt mode
```

When you give an exact task, it **context-gathers** for that specific change instead of running a full audit. When you give no context, it runs the full audit.

**UI guard:** UI references are only loaded for apps with a UI. Backend/CLI/library apps skip all UI-related modes and references automatically.

### Build Modes

| Mode | Command | Description |
|------|---------|-------------|
| `make` | `/demiurge make [feature]` | Builds on user instructions using ponytail ladder + coding standards. |
| `design-material` | `/demiurge design-material [target]` | **Only when explicitly requested. Only for UI apps.** Material Design 3 builder. |

### Evaluate Modes

| Mode | Command | Description |
|------|---------|-------------|
| `audit` | `/demiurge audit [target]` | Full codebase audit. Security, logic, dead code, style, architecture. |
| `audit-frontend` | `/demiurge audit-frontend [target]` | Frontend/UI/UX audit. Design tokens, a11y, responsive, anti-patterns. UI apps only. |
| `audit-backend` | `/demiurge audit-backend [target]` | Backend/logic/security audit. Injection, auth, error handling, type safety. |
| `critique` | `/demiurge critique [target]` | UX design review. Nielsen heuristics (/40), cognitive load, personas. UI apps only. |
| `review` | `/demiurge review [target]` | One-line code review. Severity-tagged: bug, risk, nit, q. |

### Refine Modes

| Mode | Command | Description |
|------|---------|-------------|
| `secure-code` | `/demiurge secure-code [target]` | Fixes bugs, vulnerabilities, logic errors, dead code directly. |
| `humanize` | `/demiurge humanize [target]` | Detects AI patterns in code and rewrites to sound human. |
| `polish` | `/demiurge polish [target]` | Final quality pass. Typography, spacing, color, motion, copy. UI apps only. |
| `harden` | `/demiurge harden [target]` | Production-readiness. Error handling, i18n, edge cases. |
| `bolder` | `/demiurge bolder [target]` | Amplifies bland designs. More decisive and committed. UI apps only. |
| `quieter` | `/demiurge quieter [target]` | Tones down aggressive or overstimulating designs. UI apps only. |

### Manage Modes

| Mode | Command | Description |
|------|---------|-------------|
| `debt` | `/demiurge debt [target]` | Harvests `ponytail:` comment markers into a debt ledger. |
| `compress` | `/demiurge compress [filepath]` | Compresses natural language files to save tokens. |
| `commit` | `/demiurge commit` | Generates terse conventional commit messages. |

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
├── SKILL.md                          # Main skill definition (v2.3.0)
├── README.md                         # This file
├── LICENSE                           # MIT
├── .claude-plugin/
│   └── plugin.json                   # Claude Code plugin manifest
├── references/
│   ├── iamstupid.md                  # Auto-routing from natural language
│   ├── ui/                           # UI-only references (loaded only for UI apps)
│   │   ├── audit-frontend.md
│   │   ├── bolder.md
│   │   ├── critique.md
│   │   ├── design-defaults.md
│   │   ├── design-material.md
│   │   ├── polish.md
│   │   └── quieter.md
│   ├── build/
│   │   └── make.md
│   ├── backend/
│   │   ├── audit-backend.md
│   │   └── secure-code.md
│   ├── general/
│   │   ├── audit.md
│   │   └── review.md
│   ├── standards/
│   │   ├── coding-standards.md
│   │   ├── comment-standards.md
│   │   ├── harden.md
│   │   ├── humanize.md
│   │   ├── platform-native.md
│   │   ├── structural-slop.md
│   │   └── cicd-security.md
│   └── management/
│       ├── compress.md
│       ├── debt.md
│       └── human-committing.md
└── scripts/
    ├── audit/                        # Language-specific audit scripts
    │   ├── audit-typescript-*.sh
    │   ├── audit-python.sh
    │   ├── audit-c.sh
    │   ├── audit-cpp.sh
    │   ├── audit-rust.sh
    │   ├── audit-go.sh
    │   └── audit-java.sh
    ├── lint/
    │   └── lint-all.sh               # Universal lint runner
    ├── test/
    │   └── test-runner.sh            # Universal test runner
    ├── security/
    │   ├── security-audit.sh           # Universal security audit
    │   ├── audit-github-actions.sh     # GitHub Actions security audit
    │   └── audit-dependencies.sh       # Dependency security audit
    └── compress/                     # Caveman compression (Python)
```

## License

MIT. Copyright 2026 Thavanish brijesh.
