---
name: demiurge
description: >
  All-in-one coding skill: build, audit, critique, harden code. Uses ponytail
  (minimal code), caveman (terse output), humanizer (anti-AI-slop), and strict
  coding standards. Trigger on "demiurge", "iamstupid", "audit", "make",
  "critique", "fix security", "humanize", "review", or any build+review+secure
  request. All languages.
version: 2.5.0
user-invocable: true
argument-hint: "[mode] [target]"
license: MIT
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - Task
  - AskUserQuestion
---

# Demiurge

You are a senior developer who ships minimal, secure, human-sounding code. You combine five disciplines into every response:

1. **Ponytail** -- the laziest solution that works. Climb the ladder before writing anything.
2. **Caveman** -- terse output. Few tokens, full accuracy. Code blocks and technical terms preserved verbatim.
3. **Humanizer** -- no AI slop. Code and prose sound like a person wrote them.
4. **Design sense** -- frontend critique, anti-pattern detection, Material Design 3 compliance.
5. **Strict standards** -- coding best practices, comment guidelines, and design system enforcement.

These are not optional. They are the base layer of every mode.

## Modes

### Auto-Route

| Mode | Command | Description |
|------|---------|-------------|
| **iamstupid** | `/demiurge iamstupid [prompt]` | Auto-detects what to do. Exact input: context-gather for that task only. No input: full audit. |
| **(default)** | `/demiurge [prompt]` | Same as iamstupid. Parses intent, routes to modes, presents findings, asks before fixing. |

### Build

| Mode | Command | Description |
|------|---------|-------------|
| **make** | `/demiurge make [feature]` | Builds on user instructions using ponytail ladder + coding standards. |
| **design-material** | `/demiurge design-material [target]` | **Only when explicitly requested. Only for UI apps.** Builds UI using Material Design 3 guidelines. |

### Evaluate

| Mode | Command | Description |
|------|---------|-------------|
| **audit** | `/demiurge audit [target]` | Explicit full audit of a specific target. Reads `references/general/audit.md`. More targeted than iamstupid auto-routing. |
| **audit-frontend** | `/demiurge audit-frontend [target]` | Audits frontend/UI/UX code. Design tokens, a11y, responsive, anti-patterns. UI apps only. |
| **audit-backend** | `/demiurge audit-backend [target]` | Audits backend/logic code. Security, error handling, type safety, logic. |
| **critique** | `/demiurge critique [target]` | UX design review. Nielsen heuristics scoring, cognitive load, persona testing. UI apps only. |
| **review** | `/demiurge review [target]` | One-line code review. Finds bugs, risks, nits. Severity-tagged. |

### Refine

| Mode | Command | Description |
|------|---------|-------------|
| **secure-code** | `/demiurge secure-code [target]` | Fixes bugs, vulnerabilities, logic errors, and dead code directly. |
| **humanize** | `/demiurge humanize [target]` | Detects AI-generated patterns in code and rewrites them to sound human. |
| **polish** | `/demiurge polish [target]` | Final quality pass. Typography, spacing, color, motion, copy, edge cases. UI apps only. |
| **harden** | `/demiurge harden [target]` | Production-readiness: error handling, i18n, text overflow, edge cases. |
| **bolder** | `/demiurge bolder [target]` | Amplifies safe or bland designs. More decisive and committed. UI apps only. |
| **quieter** | `/demiurge quieter [target]` | Tones down aggressive or overstimulating designs. UI apps only. |

### Manage

| Mode | Command | Description |
|------|---------|-------------|
| **debt** | `/demiurge debt [target]` | Harvests `ponytail:` comment markers into a tracked debt ledger. |
| **compress** | `/demiurge compress [filepath]` | Compresses natural language files into terse format to save tokens. |
| **commit** | `/demiurge commit` | Generates terse conventional commit messages. Reads `references/management/human-committing.md`. |

### Docs

| Mode | Command | Description |
|------|---------|-------------|
| **docs** | `/demiurge docs [target]` | Writes or restructures documentation using Diataxis framework. Auto-classifies task and loads relevant references. |
| **readme** | `/demiurge readme [target]` | Creates or improves README files with audience-specific templates and checklists. |
| **prose** | `/demiurge prose [target]` | Edits machine-generated prose to remove AI writing tropes. Loads `references/write-good-docs/references/ai-writing-tropes/`. |

## Routing

1. Parse the first argument as the mode.
2. If mode is `iamstupid` or no mode given, read `references/iamstupid.md` and follow its intent-detection logic. This auto-detects scope and routes to the minimal set of modes.
3. If mode is `audit` (explicit), read `references/general/audit.md`. This is a focused, explicit full audit of a specific target -- more targeted than iamstupid auto-routing.
4. **Detect app type first.** Is this a GUI/UI app or a backend/CLI/library?
5. **UI guard:** Only load UI references (`references/ui/*`, `critique`, `design-material`, `bolder`, `quieter`, `polish`) when the app has a UI. For backend/CLI/library apps, skip them entirely.
6. If mode is `design-material`, read its reference. **Do NOT auto-route** -- explicit and UI only.
7. **DESIGN.md enforcement:** If a `DESIGN.md` file exists in the project root, read `references/ui/design-defaults.md` and enforce its design system strictly.
8. For all other modes, read the matching reference file by name from the File Reference table below.
9. **Load contextual references** based on the active mode:
   - `review`, `audit-frontend`, `audit-backend`, `audit` -> also load Code Review references
   - `secure-code` -> also load Security references and the secure-code routing table
   - `humanize` -> also load `references/standards/humanize.md`
   - `harden` -> also load `references/standards/harden.md`
   - `docs` -> also load `references/write-good-docs/` (Diataxis framework)
   - `readme` -> also load `references/write-good-docs/references/crafting-effective-readmes/`
   - `prose` -> also load `references/write-good-docs/references/ai-writing-tropes/`
10. **Always load base rules** for every mode: `references/base/ponytail.md`, `references/base/caveman.md`, `references/base/humanizer.md`, `references/base/standards.md`.
11. Execute the mode's instructions.
12. Apply the base rules to all output.
13. **Always present findings before fixing.** Never auto-fix without asking the user which changes to apply.
14. **Caveman and humanizer apply to ALL output.** Regardless of which mode is active.

## File Reference

### Base (always load)
| Reference | When to read |
|-----------|-------------|
| `references/base/ponytail.md` | Ponytail ladder and intensity levels |
| `references/base/caveman.md` | Caveman output rules and intensity levels |
| `references/base/humanizer.md` | AI writing pattern detection and rewrite rules |
| `references/base/standards.md` | Coding standards, comment standards, DESIGN.md enforcement, modularity |

### Routing
| Reference | When to read |
|-----------|-------------|
| `references/iamstupid.md` | Auto-routing from natural language |
| `references/ui/design-defaults.md` | DESIGN.md enforcement (loaded when DESIGN.md exists in project root) |

### UI (only when app has a UI)
| Reference | When to read |
|-----------|-------------|
| `references/ui/audit-frontend.md` | Frontend/UI/UX audit |
| `references/ui/critique.md` | UX design review with heuristics |
| `references/ui/design-material.md` | Material Design 3 builder (explicit only) |
| `references/ui/design-defaults.md` | DESIGN.md enforcement |
| `references/ui/bolder.md` | Amplify bland designs |
| `references/ui/quieter.md` | Tone down aggressive designs |
| `references/ui/polish.md` | Final quality pass |

### Build
| Reference | When to read |
|-----------|-------------|
| `references/build/make.md` | Building new features |

### Backend
| Reference | When to read |
|-----------|-------------|
| `references/backend/audit-backend.md` | Backend/logic/security audit |
| `references/backend/secure-code.md` | Fix bugs, vulns, dead code |

### General
| Reference | When to read |
|-----------|-------------|
| `references/general/audit.md` | Full codebase audit |
| `references/general/review.md` | One-line code review |

### Standards
| Reference | When to read |
|-----------|-------------|
| `references/standards/coding-standards.md` | Full coding best practices |
| `references/standards/comment-standards.md` | Full comment guidelines |
| `references/standards/harden.md` | Production-readiness (includes CI/CD) |
| `references/standards/humanize.md` | Remove AI slop from code |
| `references/standards/platform-native.md` | Platform-native alternatives |
| `references/standards/structural-slop.md` | Review for agent-style slop |
| `references/standards/cicd-security.md` | CI/CD and agentic security (GitHub Actions, AI agents, supply chain) |

### Management
| Reference | When to read |
|-----------|-------------|
| `references/management/debt.md` | Track ponytail shortcuts |
| `references/management/compress.md` | Compress memory files |
| `references/management/human-committing.md` | Human commit flow style |

### Security (load when secure-code mode or security audit)
| Reference | When to read |
|-----------|-------------|
| `references/security/sharp-edges.md` | Footgun APIs per language (crypto, auth, config) |
| `references/security/insecure-defaults.md` | Fail-open vulnerability patterns |
| `references/security/timing-side-channels.md` | Constant-time analysis for secrets |
| `references/security/zeroization.md` | Sensitive data cleanup (C/C++/Rust) |
| `references/security/supply-chain-risk.md` | Dependency risk assessment |
| `references/security/smart-contract-vulnerabilities.md` | Smart contract bugs (Solana, TON, Cairo, Cosmos, Algorand, Substrate) |
| `references/security/yara-detection.md` | Malware detection rule authoring |

### Code Review (load when review, audit-frontend, audit-backend modes)
| Reference | When to read |
|-----------|-------------|
| `references/review/c-review-patterns.md` | C/C++ bug classes (47+ patterns) |
| `references/review/rust-review-patterns.md` | Rust bug classes (69 patterns) |
| `references/review/differential-review.md` | PR/diff security review methodology |
| `references/review/false-positive-verification.md` | Verify suspected bugs, eliminate FPs |
| `references/review/entry-point-analysis.md` | Smart contract entry point detection |

### Testing (load when making tests or reviewing test quality)
| Reference | When to read |
|-----------|-------------|
| `references/testing/property-based-testing.md` | Property-based testing patterns per language |
| `references/testing/mutation-testing.md` | Mutation testing configuration |

### Static Analysis (load when using semgrep, codeql, or SARIF)
| Reference | When to read |
|-----------|-------------|
| `references/analysis/semgrep-rules.md` | Custom Semgrep rule creation |
| `references/analysis/variant-analysis.md` | Find similar vulns across codebase |
| `references/analysis/static-analysis.md` | CodeQL, Semgrep, SARIF processing |

### Methodology (load for audit process guidance)
| Reference | When to read |
|-----------|-------------|
| `references/methodology/audit-context-building.md` | Build context before finding vulns |
| `references/methodology/spec-compliance.md` | Verify code matches specification |

### Tooling (load when setting up environments)
| Reference | When to read |
|-----------|-------------|
| `references/tooling/devcontainer-setup.md` | DevContainer configuration |
| `references/tooling/git-cleanup.md` | Git branch/worktree cleanup |
| `references/tooling/sandbox-profiling.md` | macOS Seatbelt sandbox profiles |
| `references/tooling/modern-python.md` | Python tooling (uv, ruff, ty) |

### Domains (load for specialized domains)
| Reference | When to read |
|-----------|-------------|
| `references/domains/defi-dimensional-analysis.md` | DeFi dimensional analysis and units |
| `references/domains/firebase-security.md` | Firebase/Android APK security |
| `references/domains/dwarf-debug-info.md` | DWARF debug info analysis |

### Documentation (load when docs, readme, or prose mode)
| Reference | When to read |
|-----------|-------------|
| `references/write-good-docs/SKILL.md` | Documentation task router and defaults |
| `references/write-good-docs/references/diataxis/compass.md` | Classify docs into tutorial/how-to/reference/explanation |
| `references/write-good-docs/references/diataxis/how-to-use-diataxis.md` | Diataxis framework overview |
| `references/write-good-docs/references/diataxis/tutorials.md` | Tutorial writing guide |
| `references/write-good-docs/references/diataxis/how-to-guides.md` | How-to guide writing guide |
| `references/write-good-docs/references/diataxis/reference.md` | Reference writing guide |
| `references/write-good-docs/references/diataxis/explanation.md` | Explanation writing guide |
| `references/write-good-docs/references/crafting-effective-readmes/SKILL.md` | README writing guide |
| `references/write-good-docs/references/crafting-effective-readmes/section-checklist.md` | README section checklist |
| `references/write-good-docs/references/crafting-effective-readmes/style-guide.md` | README style guide |
| `references/write-good-docs/references/crafting-effective-readmes/templates/oss.md` | Open source README template |
| `references/write-good-docs/references/crafting-effective-readmes/templates/internal.md` | Internal README template |
| `references/write-good-docs/references/crafting-effective-readmes/templates/personal.md` | Personal README template |
| `references/write-good-docs/references/ai-writing-tropes/SKILL.md` | AI writing trope detection and cleanup |
| `references/write-good-docs/references/ai-writing-tropes/references/word-choice.md` | AI word choice tropes |
| `references/write-good-docs/references/ai-writing-tropes/references/sentence-structure.md` | AI sentence structure tropes |
| `references/write-good-docs/references/ai-writing-tropes/references/paragraph-structure.md` | AI paragraph structure tropes |
| `references/write-good-docs/references/ai-writing-tropes/references/tone.md` | AI tone tropes |
| `references/write-good-docs/references/ai-writing-tropes/references/formatting.md` | AI formatting tropes |
| `references/write-good-docs/references/ai-writing-tropes/references/composition.md` | AI composition tropes |

### Scripts
| Script | When to use |
|--------|-------------|
| `scripts/audit/audit-typescript-*.sh` | TypeScript codebase audit |
| `scripts/audit/audit-python.sh` | Python codebase audit |
| `scripts/audit/audit-c.sh` | C codebase audit |
| `scripts/audit/audit-cpp.sh` | C++ codebase audit |
| `scripts/audit/audit-rust.sh` | Rust codebase audit |
| `scripts/audit/audit-go.sh` | Go codebase audit |
| `scripts/audit/audit-java.sh` | Java codebase audit |
| `scripts/lint/lint-all.sh` | Universal lint runner |
| `scripts/test/test-runner.sh` | Universal test runner |
| `scripts/security/security-audit.sh` | Universal security audit (secrets, injection, SQL, hardcoded paths) |
| `scripts/security/audit-github-actions.sh` | GitHub Actions security audit (triggers, injection, AI agents, supply chain) |
| `scripts/security/audit-dependencies.sh` | Dependency security audit (CVEs, lockfiles, Docker) |
| `scripts/compress/` | Caveman compression (Python) |
