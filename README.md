<div align="center">

# DEMIURGE

<img src="assets/demiurge.png" width="300" alt="demiurge"></div>

All-in-one AI skill for building, auditing, critiquing, and hardening code. Combines senior-dev laziness, token-efficient output, human-like writing, frontend design critique, and strict coding standards into one unified workflow.

## Install

### Via Skills CLI (Recommended)

```bash
npx skills add bthavanish/demiurge
```

### Claude Code (Plugin)

```bash
/plugin marketplace add bthavanish/demiurge
```

Then:

```bash
/plugin install demiurge@demiurge
```

### Manual

Clone this repo and copy `skills/demiurge/` into your agent's skills directory.

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

### Docs Modes

| Mode | Command | Description |
|------|---------|-------------|
| `docs` | `/demiurge docs [target]` | Writes or restructures documentation using Diataxis framework. |
| `readme` | `/demiurge readme [target]` | Creates or improves README files with audience-specific templates. |
| `prose` | `/demiurge prose [target]` | Edits machine-generated prose to remove AI writing tropes. |

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
├── README.md                         # This file
├── LICENSE                           # MIT
├── skills-lock.json                  # Skills lock file
├── skill/                            # Canonical source (single source of truth)
│   ├── SKILL.src.md                  # Main skill definition (v2.5.0)
│   ├── references/
│   │   ├── iamstupid.md              # Auto-routing from natural language
│   │   ├── ui/                       # UI-only references
│   │   ├── build/
│   │   ├── backend/
│   │   ├── general/
│   │   ├── standards/
│   │   ├── management/
│   │   ├── security/                 # Security analysis references
│   │   ├── review/                   # Code review references
│   │   ├── testing/                  # Testing methodology references
│   │   ├── analysis/                 # Static analysis references
│   │   ├── tooling/                  # Development tooling references
│   │   ├── methodology/              # Audit process references
│   │   └── domains/                  # Specialized domain references
│   └── scripts/
│       ├── audit/                    # Language-specific audit scripts
│       ├── lint/
│       ├── test/
│       ├── security/
│       └── compress/
├── .claude-plugin/
│   ├── marketplace.json              # Claude Code marketplace manifest
│   └── plugin.json                   # Claude Code plugin manifest
├── .claude/                          # Claude Code adapter
│   └── skills/demiurge/
│       ├── SKILL.md
│       ├── references/
│       └── scripts/
├── .opencode/                        # OpenCode adapter
│   └── skills/demiurge/
│       ├── SKILL.md
│       ├── references/
│       └── scripts/
├── .cursor/                          # Cursor adapter
│   └── skills/demiurge/
│       ├── SKILL.md
│       ├── references/
│       └── scripts/
├── .agents/                          # Generic/OpenAI adapter
│   └── skills/demiurge/
│       ├── SKILL.md
│       ├── references/
│       └── scripts/
├── .gemini/                          # Google Gemini adapter
│   └── skills/demiurge/
│       ├── SKILL.md
│       ├── references/
│       └── scripts/
├── .kiro/                            # Kiro CLI adapter
│   └── skills/demiurge/
│       ├── SKILL.md
│       ├── references/
│       └── scripts/
├── .trae/                            # Trae adapter
│   └── skills/demiurge/
│       ├── SKILL.md
│       ├── references/
│       └── scripts/
├── .trae-cn/                         # Trae CN adapter
│   └── skills/demiurge/
│       ├── SKILL.md
│       ├── references/
│       └── scripts/
├── .codex/                           # OpenAI Codex hooks
│   └── hooks.json
├── .pi/                              # Pi adapter
│   └── skills/demiurge/
│       ├── SKILL.md
│       ├── references/
│       └── scripts/
├── .qoder/                           # Qoder adapter
│   └── skills/demiurge/
│       ├── SKILL.md
│       ├── references/
│       └── scripts/
└── .rovodev/                         # Rovo Dev (Atlassian) adapter
    └── skills/demiurge/
        ├── SKILL.md
        ├── references/
        └── scripts/
```

## Credits

Demiurge stands on the shoulders of brilliant work from the security and developer tools community. Every reference, pattern, and methodology below was created by the attributed authors and is used with gratitude.

### Core Skills

These six skills form the foundation of demiurge's base rules (ponytail ladder, caveman output, humanizer, design critique, coding standards, Material Design 3).

| Skill | Author | Repository | What We Took |
|-------|--------|------------|--------------|
| **caveman** | Julius Brussee | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) | Terse output mode, intensity levels, token-efficient communication |
| **humanizer** | blader | [blader/humanizer](https://github.com/blader/humanizer) | 33 AI writing pattern detection, rewrite methodology, personality/soul guidance |
| **impeccable** | pbakaus | [pbakaus/impeccable](https://github.com/pbakaus/impeccable) | 23 UI commands (bolder, quieter, polish, critique, harden, animate, colorize, typeset, layout, delight, etc.), brand/product register awareness |
| **ponytail** | Dietrich Gebert | [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) | 7-rung ladder, intensity levels (lite/full/ultra), debt ledger, ponytail markers, testing requirement |
| **material-3-skill** | hamen | [hamen/material-3-skill](https://github.com/hamen/material-3-skill) | Material Design 3 tokens, components, theming, M3 Expressive |
| **maintainable-typescript & write-good-docs** | miguelspizza | [miguelspizza/skills](https://github.com/miguelspizza/skills) | Structural slop detection, dead code patterns, import cleanup, barrel file detection |
| **write-good-docs** | miguelspizza | [miguelspizza/skills](https://github.com/miguelspizza/skills) | Diataxis framework, audience-specific README templates, AI writing trope cleanup |

### Security and Analysis Skills (Trail of Bits)

The following 40 skills are from the [Trail of Bits skills collection](https://github.com/trailofbits/skills). Their security audit methodologies, vulnerability patterns, and analysis techniques form the backbone of demiurge's security references.

| Skill | Author(s) | What We Took |
|-------|-----------|--------------|
| **agentic-actions-auditor** | Trail of Bits | GitHub Actions security, AI agent prompt injection (9 attack vectors A-I), CI/CD security audit methodology |
| **sharp-edges** | Trail of Bits | Footgun APIs across 11 languages (C, Go, Rust, Swift, Java, Kotlin, C#, PHP, JavaScript, Python, Ruby), crypto API dangers, config pitfalls |
| **insecure-defaults** | Trail of Bits | Fail-open vulnerability patterns, 6 categories of insecure defaults, verification workflow |
| **constant-time-analysis** | Trail of Bits | Timing side-channel detection across 12+ languages, dangerous instruction identification, safe alternatives |
| **zeroize-audit** | Trail of Bits | 11 zeroization finding categories, LLVM IR analysis, Rust-specific patterns, proof-of-concept generation |
| **supply-chain-risk-auditor** | Spencer Michaels | 6 dependency risk factors, maintainer health evaluation, risk assessment workflow |
| **yara-authoring** | Trail of Bits | YARA-X rule authoring, string quality tiers, atom theory, platform-specific detection (DEX, CRX, PE) |
| **c-review** | Trail of Bits | 47+ C/C++ bug classes across 8 clusters, threat-model-driven review, parallel worker orchestration |
| **rust-review** | Trail of Bits | 69 Rust bug classes across 13 clusters, unsafe boundary analysis, FFI safety, async runtime detection |
| **differential-review** | Omar Inuwa | 7-phase PR/diff security review, blast radius quantification, adversarial vulnerability modeling |
| **fp-check** | Trail of Bits | Standard vs deep verification paths, 6 mandatory gates, 13 false-positive patterns, bug-class-specific verification |
| **entry-point-analyzer** | Trail of Bits | Smart contract entry point detection for 6 languages (Solidity, Vyper, Solana, Move, TON, CosmWasm), role detection |
| **property-based-testing** | Trail of Bits | Property catalog (10 types), strength hierarchy, pattern detection per language, refactoring patterns |
| **mutation-testing** | Trail of Bits | Mutation testing configuration, per-file targeting, severity filtering, two-phase campaigns |
| **semgrep-rule-creator** | Maciej Domanski | Custom Semgrep rule creation, taint mode methodology, test-first approach |
| **semgrep-rule-variant-creator** | Trail of Bits | Cross-language rule porting, applicability analysis, per-language validation |
| **variant-analysis** | Axel Mierczuk | Finding similar vulnerabilities, abstraction ladder, CodeQL/Semgrep query templates |
| **static-analysis** | Axel Mierczuk, Paweł Płatek | CodeQL scanning, Semgrep scanning, SARIF processing and deduplication |
| **audit-context-building** | Omar Inuwa | 3-phase context building, per-function micro-analysis, anti-hallucination rules |
| **spec-to-code-compliance** | Omar Inuwa | IR-based spec compliance verification, divergence classification, exploit scenario generation |
| **devcontainer-setup** | Trail of Bits | DevContainer auto-detection, security sandboxing (bubblewrap, network isolation), CLI helper |
| **git-cleanup** | Trail of Bits | Git branch/worktree cleanup, 7 branch categories, two-confirmation gates |
| **seatbelt-sandboxer** | Spencer Michaels | macOS Seatbelt sandbox profiling, default-deny allowlists, iterative testing methodology |
| **modern-python** | William Tan | Python tooling (uv, ruff, ty), migration checklists, security hooks, pyproject.toml config |
| **dimensional-analysis** | Trail of Bits | DeFi dimensional analysis, 12 bug patterns, dimension algebra, standard DeFi units |
| **firebase-apk-scanner** | Trail of Bits | Firebase security scanning, 14 vulnerability categories, APK config extraction |
| **dwarf-expert** | Evan Hellman | DWARF debug info analysis (v3-v5), verification workflows, coding guidelines |
| **burpsuite-project-parser** | Will Vandevanter | Burp Suite project file parsing, severity/confidence triage |
| **ask-questions-if-underspecified** | Kevin Valerio | Requirement clarification methodology, minimum question sets |
| **culture-index** | Dan Guido | Behavioral survey interpretation, team composition analysis, burnout detection |
| **debug-buttercup** | Trail of Bits | Buttercup CRS debugging on Kubernetes, 7 failure patterns, diagnostic methodology |
| **gh-cli** | Trail of Bits | GitHub URL interception, authenticated CLI access, session-scoped cloning |
| **let-fate-decide** | Trail of Bits | Tarot-based entropy injection for planning (12 Houses spread) |
| **second-opinion** | Trail of Bits | External LLM code review (OpenAI Codex, Gemini CLI), structured findings output |
| **testing-handbook-skills** | Trail of Bits | Testing Handbook skill generation, 16 security testing tool/technique skills |
| **trailmark** | Trail of Bits | Source code graph parsing, pre-analysis passes (blast radius, taint, privilege boundaries) |
| **workflow-skill-design** | Trail of Bits | Skill design patterns, anti-patterns, progressive disclosure, tool assignment |
| **skill-improver** | Trail of Bits | Iterative skill quality improvement, fix-review cycles |
| **claude-in-chrome-troubleshooting** | jeffzwang (ExaAILabs) | Claude in Chrome MCP extension connectivity troubleshooting |

### Additional References

| Source | What We Took |
|--------|--------------|
| [Trail of Bits Testing Handbook](https://appsec.guide) | Security testing methodologies, tool configurations, vulnerability detection techniques |
| [Wikipedia: Signs of AI Writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) | 33 AI writing patterns for the humanizer skill |
| [Trail of Bits agentic-actions-auditor](https://github.com/trailofbits/skills/tree/main/plugins/agentic-actions-auditor) | CI/CD security audit methodology, 9 attack vector detection patterns |

## License

MIT. Copyright 2026 Thavanish brijesh.

### Third-Party Licenses

The references incorporated from the Trail of Bits skills collection and other sources are used under their respective licenses. See individual repositories for license details. Most Trail of Bits skills are released under the [MIT License](https://github.com/trailofbits/skills/blob/main/LICENSE).
