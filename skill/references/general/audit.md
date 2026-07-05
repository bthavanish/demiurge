# Audit Mode (Full Codebase)

Audit every file in the codebase. Generate a comprehensive report covering security, logic, dead code, style violations, and architecture issues.

## Workflow

1. **Discover the codebase.** Use Glob to find all source files. Identify languages, frameworks, and project structure.

2. **Scan each file.** Read every source file. Apply the checks below.

3. **Generate the report.** Use the report template at the end of this file.

4. **Prioritize findings.** Tag each finding with severity: P0 (critical), P1 (high), P2 (medium), P3 (low).

## Checks (apply to every file)

### Security
- Hard-coded secrets, tokens, passwords, API keys
- SQL injection vectors (string concatenation in queries)
- XSS vectors (unescaped user input in HTML/templates)
- Path traversal (unvalidated file paths from user input)
- Unsafe deserialization
- Missing input validation at trust boundaries
- Insecure cryptography (MD5, SHA1 for security, weak random)
- Race conditions in concurrent access
- Missing authentication/authorization checks

### Logic
- Null/undefined dereference without guards
- Off-by-one errors in loops or array access
- Unreachable code paths
- Missing error handling (swallowed exceptions, empty catch blocks)
- Incorrect boolean logic (De Morgan violations, truthiness traps)
- Type coercion bugs
- Integer overflow/underflow in languages where it matters
- Incorrect comparison operators (== vs ===, assignment in conditionals)

### Dead Code
- Unused imports, variables, functions, classes
- Commented-out code blocks
- Unreachable branches
- Deprecated functions still in use
- Redundant conditionals (always true/false)

### Style and Naming
- Single-letter variable names (except loop counters)
- Arbitrary names (data2, temp, flag, result)
- Inconsistent naming conventions within the same file
- Magic numbers without named constants
- Functions that do more than one thing (SRP violation)
- Deeply nested code (>3 levels of nesting)

### Architecture
- Circular dependencies between modules
- God objects or god functions (>100 lines)
- Tight coupling between unrelated modules
- Missing abstraction at trust boundaries
- Configuration values hardcoded that should be external

## Context Building (Pre-Audit)

Before deep audit, build architectural context using the 3-phase process:

### Phase 1: Initial Orientation (Bottom-Up Scan)
1. Identify major modules/files/contracts
2. Note obvious public/external entrypoints
3. Identify likely actors (users, owners, relayers, oracles)
4. Identify important storage variables, dicts, state structs
5. Build preliminary structure without assuming behavior

### Phase 2: Ultra-Granular Function Analysis
For every non-trivial function, analyze:
- **Purpose** -- why it exists and its role in the system
- **Inputs & Assumptions** -- parameters, implicit inputs, preconditions, trust assumptions
- **Outputs & Effects** -- return values, state writes, events, external interactions
- **Block-by-block analysis** -- what each block does, why it's here, what it depends on
- **Cross-function dependencies** -- internal/external calls, shared state, invariant couplings

### Phase 3: Global System Understanding
1. **State & invariant reconstruction** -- map reads/writes of each state variable, derive multi-function invariants
2. **Workflow reconstruction** -- identify end-to-end flows, track state transforms
3. **Trust boundary mapping** -- actor -> entrypoint -> behavior, untrusted input paths
4. **Complexity clustering** -- functions with many assumptions, high branching, multi-step dependencies

## Spec Compliance (If Spec Exists)

When a specification or design document is available, verify code matches it:

### Process
1. **Documentation discovery** -- identify all specs, whitepapers, design docs
2. **Normalize** -- extract semantic cues: architecture, invariants, formulas, trust models
3. **Extract spec intent** -- protocol purpose, actors, variables, preconditions, invariants, formulas, flows, security requirements
4. **Extract code behavior** -- line-by-line semantic analysis: state reads/writes, conditions, external calls, events
5. **Compare** -- for each spec item, locate related code behavior and classify match type
6. **Classify divergences** -- CRITICAL (exploitable), HIGH (incorrect impl), MEDIUM (ambiguous), LOW (drift)

### Match Types
| Type | Meaning |
|------|---------|
| full_match | Code implements exactly what spec requires |
| partial_match | Code partially implements -- investigate further |
| mismatch | Spec says X, code does Y |
| missing_in_code | Spec requirement has no corresponding code |
| code_stronger_than_spec | Code has additional protections not in spec |
| code_weaker_than_spec | Code implementation is weaker than spec |

## Report Template

```markdown
# Codebase Audit Report

**Date:** [date]
**Files scanned:** [count]
**Languages:** [list]

## Summary

| Severity | Count |
|----------|-------|
| P0 (Critical) | [n] |
| P1 (High) | [n] |
| P2 (Medium) | [n] |
| P3 (Low) | [n] |

## Findings

### P0 - Critical

#### [Finding title]
- **File:** `path/to/file.ext:line`
- **Category:** Security | Logic | Dead Code | Style | Architecture
- **Issue:** [description]
- **Fix:** [concrete fix]

### P1 - High
[same format]

### P2 - Medium
[same format]

### P3 - Low
[same format]

## Recommendations

1. [Highest-impact fix]
2. [Second-highest]
3. [Third-highest]
```

## Rules

- Read every source file. Do not skip files based on assumptions.
- Report exact file paths and line numbers.
- Provide concrete fixes, not vague suggestions.
- Group related findings. Do not repeat the same issue across multiple entries when one fix addresses all instances.
- If the codebase is large (>200 files), prioritize: security first, then logic, then dead code, then style.
- For spec compliance: never infer unspecified behavior. Always cite exact evidence. Classify ambiguity instead of guessing.

## Production Readiness (Harden)

Production-readiness checklist: error handling, i18n, text overflow, edge cases.

### Error Handling
- Every async operation has error handling
- User-facing errors explain what happened in plain language
- Developer errors include technical cause
- No swallowed exceptions (empty catch blocks)
- Resources cleaned up in error paths (finally, defer, try-with-resources)
- Network calls have timeouts
- Retries have max attempts

### Internationalization (i18n)
- All user-facing strings extracted to translation files
- No hardcoded strings in templates/components
- Date/time formatting uses locale-aware APIs
- Number formatting uses locale-aware APIs
- Text expansion accounted for (German 30% longer than English)
- RTL layout support if needed

### Text Overflow
- Test every heading and paragraph at narrow viewports
- Long words wrapped with `overflow-wrap: break-word`
- Truncation with ellipsis where appropriate
- No text clipping at any breakpoint

### Edge Cases
- Empty states with helpful guidance
- Loading states with appropriate indicators
- Boundary values (0, max, negative, overflow)
- Concurrent access / race conditions
- Network failure graceful degradation
- Invalid user input handling
- Session expiry handling

### Security
- Input validation at all trust boundaries
- Output encoding for HTML, CSS, JS contexts
- CSRF protection on state-changing operations
- Rate limiting on sensitive endpoints
- No secrets in client-side code
- Secure headers (CSP, X-Frame-Options, etc.)

### CI/CD Security
- GitHub Actions: no `pull_request_target` with PR head checkout
- GitHub Actions: no `${{ github.event.* }}` in `run:` blocks (script injection)
- GitHub Actions: `permissions:` block with minimum required permissions
- GitHub Actions: no wildcard user/bot allowlists
- GitHub Actions: AI agent prompts do not receive attacker-controlled input
- Dependencies: no known CVEs (`npm audit`, `pip-audit`, `cargo audit`)
- Docker: pinned base images, non-root user, multi-stage builds

### Resilience
- Circuit breaker for external services
- Graceful degradation when dependencies fail
- Health check endpoints
- Structured logging at boundaries
- Metrics for critical operations
