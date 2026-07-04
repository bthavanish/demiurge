# I Am Stupid Mode

Auto-detect what the user needs from their prompt and run the right modes. No memorization of mode names required.

## How It Works

The user types natural language. You parse intent and route to the correct modes.

### Input Patterns

| User says | Routes to | Action |
|-----------|-----------|--------|
| `/demiurge` (no args) | `audit` | Scan codebase, generate report, ask which fixes to apply |
| `/demiurge iamstupid` (no args) | `audit` | Same as above |
| `/demiurge iamstupid [natural language]` | Parsed | Detect intent, route to modes |
| `/demiurge [natural language]` | Parsed | Detect intent, route to modes |

### Intent Detection Rules

Scan the user's words for these signals:

**Security signals:** "secure", "vulnerability", "hack", "injection", "auth", "password", "token", "secret", "exploit", "attack", "CVE"
-> Run: `audit-backend` (security focus) or `secure-code` (fix immediately)

**Frontend/UI signals:** "frontend", "UI", "component", "page", "layout", "design", "responsive", "mobile", "CSS", "style", "button", "form", "dashboard", "landing"
-> Run: `audit-frontend` or `critique` if it's about design quality

**Backend signals:** "API", "endpoint", "server", "database", "query", "route", "middleware", "backend", "service", "handler"
-> Run: `audit-backend`

**Quality signals:** "clean", "refactor", "improve", "quality", "slop", "AI", "messy", "ugly", "bad code", "smell"
-> Run: `humanize` or `review`

**Build signals:** "build", "create", "make", "add", "implement", "write", "new feature", "new component"
-> Run: `make`

**Audit signals:** "audit", "scan", "check", "review", "analyze", "inspect", "look at"
-> Run: `audit` (full) or targeted audit based on other signals

**Fix signals:** "fix", "bug", "error", "broken", "crash", "failing", "issue"
-> Run: `secure-code` or `review` first, then fix

**Production signals:** "deploy", "production", "ship", "launch", "ready", "hardening"
-> Run: `harden`

**Design signals:** "bold", "bland", "boring", "loud", "quiet", "aggressive", "subtle", "polish"
-> Run: `bolder`, `quieter`, or `polish` based on context

**Debt signals:** "debt", "shortcuts", "ponytail", "markers", "TODO", "technical debt"
-> Run: `debt`

**Compress signals:** "compress", "shrink", "tokens", "save tokens", "memory file"
-> Run: `compress`

### Multi-Mode Routing

If the user's prompt triggers multiple signals, run multiple modes:

```
"audit my frontend code for security" -> audit-frontend + audit-backend (security)
"make it look better and fix bugs" -> polish + secure-code
"clean up this mess" -> humanize + review
"ship this to production" -> harden + audit
```

### Default Behavior (no args)

When called with no arguments (`/demiurge` or `/demiurge iamstupid`):

1. **Discover the codebase.** Glob for all source files. Identify languages and structure.
2. **Run `audit`** on the entire codebase.
3. **Generate the report** with P0-P3 findings.
4. **Present the report** to the user.
5. **Ask:** "Which of these would you like me to fix? Pick by number or describe what you want."
6. **Apply fixes** for the issues the user selects.

### Flow

```
User: /demiurge iamstupid fix the security issues in my api

You: [Parse: security + api -> audit-backend + secure-code]
     [Run audit-backend on src/api/]
     [Present findings]
     [Ask which to fix]
     [Apply fixes with secure-code]
```

```
User: /demiurge

You: [No args -> default audit flow]
     [Scan entire codebase]
     [Generate report]
     [Present findings]
     [Ask which to implement]
```

### Rules

- Always present findings before fixing. Never auto-fix without asking.
- When routing to multiple modes, run them in a logical order (audit first, then fix).
- If intent is ambiguous, ask one clarifying question, not five.
- If the user just says `/demiurge` with no context, run the full audit and ask.
- Group related findings when presenting. Don't dump raw output.
- After presenting a report, always end with a question about what to fix.
