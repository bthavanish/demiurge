# I Am Stupid Mode

Auto-detect what the user needs from their prompt and run the right modes. No memorization of mode names required.

## Two Behaviors

### 1. Exact Input (user says what they want)

User provides a specific task. Do NOT run a full audit. Instead:

1. **Detect the app type.** Is this a GUI/UI app or a backend/CLI/library?
2. **Gather only the context needed** for that specific change.
3. **Route to the minimal set of modes** that solve the exact request.
4. **Execute.** Present findings for that specific scope only.

```
User: /demiurge fix the auth in my api

You: [Detect: backend/CLI app -> skip UI refs]
     [Gather context: read src/auth/, src/api/]
     [Route: audit-backend (security)]
     [Present findings]
     [Ask: "Which of these would you like me to fix?"]
     [Apply fixes for selected issues]
```

```
User: /demiurge add a settings page

You: [Detect: UI app -> load UI refs]
     [Gather context: read existing pages, component patterns]
     [Route: make]
     [Build settings page following existing patterns]
```

### 2. No Input (user says just `/demiurge`)

User provides no context. Run the full audit flow:

1. **Discover the codebase.** Glob for all source files. Identify languages, structure, and whether it's a GUI or non-GUI app.
2. **Run `audit`** on the entire codebase.
3. **Generate the report** with P0-P3 findings.
4. **Present the report** to the user.
5. **Ask:** "Which of these would you like me to fix?"
6. **Apply fixes** for the issues the user selects.

## App Type Detection

Before loading any references, detect the app type:

| Signal | Type | UI refs loaded? |
|--------|------|-----------------|
| `*.tsx`, `*.jsx`, `*.vue`, `*.svelte`, `index.html`, `DESIGN.md`, `package.json` with react/vue/angular/svelte | UI app | Yes |
| `*.py`, `*.go`, `*.rs`, `*.c`, `*.java`, `*.cpp` with no HTML/CSS | Backend/CLI/library | **No** |
| Mixed (e.g., Express + React) | Full stack | Yes |

**UI references are ONLY loaded when the app has a UI.** For backend/CLI/library apps, skip:
- `references/ui/*` (all of them)
- `references/standards/platform-native.md` (only if no web frontend)
- `design-material`, `critique`, `bolder`, `quieter`, `polish` modes

## Intent Detection Rules

Scan the user's words for these signals:

**Security signals:** "secure", "vulnerability", "hack", "injection", "auth", "password", "token", "secret", "exploit", "attack", "CVE"
-> Route: `audit-backend` (security focus), then offer `secure-code` if user wants fixes

**Frontend/UI signals:** "frontend", "UI", "component", "page", "layout", "design", "responsive", "mobile", "CSS", "style", "button", "form", "dashboard", "landing"
-> Route: `audit-frontend` or `critique` if it's about design quality
-> **Only if app has a UI**

**Backend signals:** "API", "endpoint", "server", "database", "query", "route", "middleware", "backend", "service", "handler"
-> Route: `audit-backend`

**Quality signals:** "clean", "refactor", "improve", "quality", "slop", "AI", "messy", "ugly", "bad code", "smell"
-> Route: `humanize` or `review`

**Build signals:** "build", "create", "make", "add", "implement", "write", "new feature", "new component"
-> Route: `make`

**Audit signals:** "audit", "scan", "check", "review", "analyze", "inspect", "look at"
-> Route: `audit` (full) or targeted audit based on other signals

**Fix signals:** "fix", "bug", "error", "broken", "crash", "failing", "issue"
-> Route: `review` first to identify issues, then offer `secure-code` to fix selected findings

**Production signals:** "deploy", "production", "ship", "launch", "ready", "hardening"
-> Route: `harden`

**Design signals:** "bold", "bland", "boring", "loud", "quiet", "aggressive", "subtle", "polish"
-> Route: `bolder`, `quieter`, or `polish` based on context
-> **Only if app has a UI**

**Debt signals:** "debt", "shortcuts", "ponytail", "markers", "TODO", "technical debt"
-> Route: `debt`

**Compress signals:** "compress", "shrink", "tokens", "save tokens", "memory file"
-> Route: `compress`

## Multi-Mode Routing

If the user's prompt triggers multiple signals, run multiple modes:

```
"audit my frontend code for security" -> audit-frontend + audit-backend (security)
"make it look better and fix bugs" -> polish + review, then secure-code if user approves
"clean up this mess" -> humanize + review
"ship this to production" -> harden + audit
"fix the memory leak in my C parser" -> review (C patterns), then secure-code if user approves
```

## Reference Loading Guard

Only load references relevant to the detected context:

| App Type | Load | Skip |
|----------|------|------|
| **UI app** | All references | None |
| **Backend/CLI** | `build/`, `backend/`, `general/`, `standards/` (except platform-native for web), `management/` | `ui/*`, `critique`, `design-material`, `bolder`, `quieter`, `polish` |
| **Library** | `build/`, `general/`, `standards/`, `management/` | `ui/*`, `backend/*`, `critique`, `design-material`, `bolder`, `quieter`, `polish` |
| **Unknown** | `general/`, `standards/`, `management/` | Everything else until detected |

### Rules

- Always present findings before fixing. Never auto-fix without asking.
- When routing to multiple modes, run them in a logical order (audit first, then fix).
- If intent is ambiguous, ask one clarifying question, not five.
- If the user just says `/demiurge` with no context, run the full audit and ask.
- Group related findings when presenting. Don't dump raw output.
- After presenting a report, always end with a question about what to fix.
- Caveman and humanizer rules apply to ALL output, regardless of which mode is active.
