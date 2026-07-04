# Secure Code Mode

Scan code for bugs, vulnerabilities, logic errors, and dead code. Fix everything. This mode combines the audit checks with immediate remediation.

## Workflow

1. **Discover code.** Find all source files in the project.

2. **Scan.** Apply every check from the backend audit (`references/audit-backend.md`) plus the additional checks below.

3. **Fix.** For each finding, apply the fix directly. Do not just report -- fix.

4. **Verify.** Run lint, typecheck, or tests after fixing. Ensure the fix does not break anything.

5. **Report.** Summarize what was found and fixed.

## What This Mode Fixes

### Security Vulnerabilities
- Hard-coded secrets -> move to environment variables or config
- SQL injection -> parameterized queries
- XSS -> output encoding/escaping
- Path traversal -> validate and sanitize paths
- Unsafe deserialization -> safe alternatives
- Missing input validation -> add validation at boundaries
- Insecure crypto -> upgrade to secure algorithms
- SSRF -> validate and whitelist URLs
- Missing auth checks -> add authentication gates
- Race conditions -> proper locking or atomic operations

### Logic Errors
- Null dereference -> add guards or use optional chaining
- Off-by-one -> fix loop bounds
- Incorrect boolean logic -> rewrite conditions
- Type coercion bugs -> strict comparisons
- Missing error handling -> add proper error propagation
- Swallowed exceptions -> log and rethrow or handle
- Unreachable code -> remove
- Missing break in switch -> add break or fallthrough comment

### Dead Code
- Unused imports -> remove
- Unused variables -> remove
- Unused functions -> remove (check callers first)
- Commented-out code -> remove
- Unreachable branches -> remove
- Deprecated usage -> upgrade

### Code Quality
- Magic numbers -> named constants with provenance
- Single-letter names -> descriptive names
- Functions doing too many things -> split
- Deep nesting -> extract early returns or helper functions
- Inconsistent naming -> align with codebase convention
- Missing immutability -> make final/const where practical

## Fix Principles

- **Root cause, not symptom.** Grep every caller of a touched function. Fix once in the shared code.
- **Minimal diff.** Fix the bug with the smallest change that addresses the root cause.
- **Do not refactor unrelated code.** Stay focused on the finding. Refactoring is a separate task.
- **Preserve behavior.** The fix must not change observable behavior except to fix the bug.
- **Add a guard, not a comment.** If code is fragile, add a runtime check, not a comment saying "be careful."
- **Test the fix.** If there is a test runner, run it. If not, add one assert-based self-check for non-trivial fixes.

## Output

After fixing, output:

```
## Fixes Applied

| # | File | Issue | Fix |
|---|------|-------|-----|
| 1 | path/file:line | [issue] | [what was done] |
| 2 | ... | ... | ... |

## Skipped

[list of findings that were intentionally not fixed, with reasoning]
```

Code changes are applied directly to the files. No separate patch files.

## Rules

- Fix everything. Do not leave findings unfixed unless there is a clear reason (would break API, requires architectural change, user explicitly said not to).
- If a fix would require a large refactor, fix what you can and note the rest as "requires refactor."
- Never introduce new vulnerabilities while fixing existing ones.
- Run available tests/lint after fixing.
- Commit-style output: concise, what was done and why.
