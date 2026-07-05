# Standards Reference

Coding standards, platform-native alternatives, structural slop detection, CI/CD security.

---

## Coding Standards

### Prerequisites

- Understand before coding. Read the task and the code it touches.
- Know requirements (functional + non-functional).
- Respect the architecture.

### Simplicity (KISS)

- Most readable, straightforward solution. No over-engineering.
- SRP: every function/class/module does one thing.
- Three similar lines is better than a premature `createHelper()`.

### Naming

- Descriptive, self-explanatory names. No single-letter vars (except loop counters).
- No arbitrary names (data2, temp, flag, result).
- 100% consistency with existing codebase conventions.

### Constants and Immutability

- No magic numbers. Declare named constants.
- Default to immutability (final/const wherever practical).

### Comments

- Comment the **why**, not the **what**.
- Code is documentation through descriptive naming.
- Use standard doc formats for public APIs (JSDoc, docstrings).
- No version history, author names, or commented-out dead code.
- Mark intentional simplifications with `ponytail:` comments.

### Other Rules

- Portable: no hard-coded URLs, paths, IPs. Use config/env vars.
- No hallucinations: only standard features or explicitly provided libraries.
- Error handling: never swallow exceptions silently. Clean up in error paths.
- Dead code: if replaced, remove it. No commented-out code.
- Testing: assert on observable outcomes, not mock counts.

---

## Platform-Native Alternatives

The lazy senior dev's first question: does the platform already do this?

### HTML Elements

| You think you need | Platform has |
|---|---|
| Date picker library | `<input type="date">` |
| Dialog library | `<dialog>` + `dialog.showModal()` |
| Accordion component | `<details><summary>Title</summary>...</details>` |
| Tooltip library | `title` attribute + CSS |
| Searchable dropdown | `<input list="id"> <datalist>` |

### CSS

| You think you need JS for | CSS has |
|---|---|
| Responsive font | `font-size: clamp(1rem, 2.5vw, 2rem)` |
| Dark mode | `@media (prefers-color-scheme: dark)` |
| Responsive layout | `grid-template-columns: repeat(auto-fill, minmax(250px, 1fr))` |
| Global design tokens | CSS custom properties (`--color-primary: #7c3aed`) |

### JavaScript

| You think you need | Platform has |
|---|---|
| `lodash.clonedeep` | `structuredClone(obj)` |
| `lodash.groupby` | `Object.groupBy(arr, fn)` |
| `uuid` (v4) | `crypto.randomUUID()` |
| `query-string` | `new URLSearchParams(location.search)` |
| Clipboard | `navigator.clipboard.writeText(text)` |

### Node.js

| You think you need | Node has |
|---|---|
| `mkdirp` | `fs.mkdirSync(path, { recursive: true })` |
| `rimraf` | `fs.rmSync(path, { recursive: true, force: true })` |
| `uuid` (v4) | `crypto.randomUUID()` |

### Python

| You think you need | Python has |
|---|---|
| `python-dateutil` (basic) | `datetime.fromisoformat()` (3.7+) |
| `pytz` | `zoneinfo.ZoneInfo()` (3.9+) |
| `attrs` (simple data) | `@dataclass` |
| `pathlib2` | `pathlib.Path` (built-in since 3.4) |

---

## Structural Slop Detection

AI slop = code that looks locally defensive but weakens the system contract. Finds places preserving uncertainty instead of resolving into types, schemas, owners, or real boundaries.

### Patterns

- **Shape churn:** `normalize*`, `to*`, `map*`, `adapt*` shapes between internal callers
- **Boundary theater:** validation/fallback inside already-typed internal code
- **Optionality creep:** `input?.field` where caller should be required
- **Helper confetti:** one-call helpers, forwarding helpers
- **Spread fog:** object spreads hiding final shape
- **Fake extensibility:** hooks, options bags, strategies with one real use
- **Error laundering:** `try/catch` that only rewrites internal errors
- **Type erosion:** `unknown`, `Record<string, unknown>`, casts where named domain type should exist
- **Defensive defaults:** empty objects, empty arrays hiding programmer errors

### Structural Hygiene

- Dead code. Unused files, functions, types. No commented-out code.
- Import hygiene. Unused imports, stale imports.
- Barrel files. Prefer direct imports.
- Circular dependencies. Dependencies flow one direction.
- Export hygiene. Export only what's needed.

### Rules

- Validate at external boundaries only.
- Make required state required.
- Prefer one canonical shape at the source.
- Delete adapters, wrappers, defaults that don't protect a real public boundary.
- Throw upward except at top-level operational boundaries.

---

## CI/CD and Agentic Security

### GitHub Actions Dangerous Triggers

| Trigger | Risk |
|---|---|
| `pull_request_target` | Runs in base branch with secrets. External PRs can trigger. |
| `issue_comment` | Comment body is attacker-controlled input. |
| `workflow_dispatch` | Input values are user-controlled. |

### Script Injection

```yaml
# VULNERABLE: expression in run block
- run: echo "${{ github.event.issue.title }}"

# SAFE: use env var
- run: echo "$ISSUE_TITLE"
  env:
    ISSUE_TITLE: ${{ github.event.issue.title }}
```

### AI Agent Security

When workflows invoke AI agents, attacker-controlled input reaches the agent through:
1. Direct injection in prompt fields
2. Env var intermediary (env var set from `${{ }}`, prompt reads env var)
3. Runtime fetch (`gh issue view` returns attacker body)

### Permissions

- Use `permissions:` block in every workflow
- Grant minimum required permissions
- Never use `permissions: write-all`

### Supply Chain

- Typosquatting, dependency confusion, compromised maintainer, transitive vulnerabilities
- Detection: `npm audit`, `pip-audit`, `cargo audit`, `govulncheck`
- Docker: pin base images, multi-stage builds, non-root user, scan with trivy
