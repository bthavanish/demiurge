# Differential Security Review

Security-focused code review for PRs, commits, and diffs. Analyzes code changes against a baseline, calculates blast radius, checks test coverage, and generates comprehensive markdown reports.

---

## Core Principles

1. **Risk-First**: Focus on auth, crypto, value transfer, external calls
2. **Evidence-Based**: Every finding backed by git history, line numbers, attack scenarios
3. **Adaptive**: Scale to codebase size (SMALL/MEDIUM/LARGE)
4. **Honest**: Explicitly state coverage limits and confidence level
5. **Output-Driven**: Always generate comprehensive markdown report file

---

## 7-Phase Workflow

```
Pre-Analysis -> Phase 0: Triage -> Phase 1: Code Analysis -> Phase 2: Test Coverage
                    |                     |                        |
Phase 3: Blast Radius -> Phase 4: Deep Context -> Phase 5: Adversarial -> Phase 6: Report
```

### Pre-Analysis: Baseline Context Building

Build complete baseline understanding before analyzing changes:

1. Checkout baseline commit
2. Capture system-wide invariants (what must ALWAYS be true)
3. Map trust boundaries and privilege levels
4. Document validation patterns (defense-in-depth)
5. Build call graphs for critical functions
6. Trace state flow diagrams
7. Note external dependencies and trust assumptions

**Why this matters**: Understand what the code was SUPPOSED to do before changes, identify implicit security assumptions, detect when changes violate baseline invariants.

### Phase 0: Intake & Triage

**Extract changes:**

```bash
git diff <base>..<head> --stat
git log <base>..<head> --oneline
gh pr view <number> --json files,additions,deletions
```

**Assess codebase size:**

| Codebase Size | Strategy | Approach |
|---------------|----------|----------|
| SMALL (<20 files) | DEEP | Read all deps, full git blame |
| MEDIUM (20-200) | FOCUSED | 1-hop deps, priority files |
| LARGE (200+) | SURGICAL | Critical paths only |

**Risk score each file:**

| Risk Level | Triggers |
|------------|----------|
| HIGH | Auth, crypto, external calls, value transfer, validation removal |
| MEDIUM | Business logic, state changes, new public APIs |
| LOW | Comments, tests, UI, logging |

### Phase 1: Changed Code Analysis

For each changed file:

1. Read both versions (baseline and changed)
2. Analyze each diff region: BEFORE / AFTER / CHANGE / SECURITY
3. Git blame removed code — check for security-related removals
4. Check for regressions (re-added code previously removed for security)
5. Micro-adversarial analysis per change
6. Generate concrete attack scenarios

**Detection commands:**

```bash
# Find code removed for security
git log -S "removed_code" --all --grep="security|fix|CVE"
git blame <baseline> -- file.sol | grep "pattern"

# Check for regressions
git log -S "added_code" --all -p
```

### Phase 2: Test Coverage Analysis

Identify coverage gaps and elevate risk:

- NEW function + NO tests -> Elevate risk MEDIUM to HIGH
- MODIFIED validation + UNCHANGED tests -> HIGH RISK
- Complex logic (>20 lines) + NO tests -> HIGH RISK

```bash
git diff <range> --name-only | grep -v "test"
git diff <range> --name-only | grep "test"
grep -r "test.*functionName" test/ --include="*.sol" --include="*.js"
```

### Phase 3: Blast Radius Analysis

**Calculate impact:**

```bash
grep -r "functionName(" --include="*.sol" . | wc -l
```

| Blast Radius | Classification |
|-------------|----------------|
| 1-5 calls | LOW |
| 6-20 calls | MEDIUM |
| 21-50 calls | HIGH |
| 50+ calls | CRITICAL |

**Priority matrix:**

| Change Risk | Blast Radius | Priority | Analysis Depth |
|-------------|--------------|----------|----------------|
| HIGH | CRITICAL | P0 | Deep + all deps |
| HIGH | HIGH/MEDIUM | P1 | Deep |
| HIGH | LOW | P2 | Standard |
| MEDIUM | CRITICAL/HIGH | P1 | Standard + callers |

### Phase 4: Deep Context Analysis

For each HIGH RISK changed function:

1. Map complete function flow (entry conditions, state reads/writes, external calls)
2. Trace internal calls recursively
3. Trace external calls and trust boundaries
4. Identify invariants (what must ALWAYS be true, what must NEVER happen)
5. Five Whys root cause analysis

**Cross-cutting pattern detection:**

```bash
grep -r "require.*amount > 0" --include="*.sol" .
git diff <range> | grep "^-.*require.*amount > 0"
```

### Phase 5: Adversarial Modeling

Apply to all HIGH RISK changes. Five-step methodology:

**Step 1 — Define Attacker Model:**

| Question | Options |
|----------|---------|
| WHO | Unauthenticated user, authenticated user, malicious admin, compromised contract, MEV bot |
| ACCESS | Public API only, authenticated role, specific permissions, contract call capabilities |
| WHERE | HTTP endpoints, smart contract functions, RPC interfaces, external APIs |

**Step 2 — Identify Concrete Attack Vectors:**

```
ENTRY POINT: [Exact function/endpoint]
ATTACK SEQUENCE:
  1. [Specific API call/transaction]
  2. [How this reaches vulnerable code]
  3. [What happens in vulnerable code]
  4. [Impact achieved]
PROOF OF ACCESSIBILITY:
  - Function is public/external
  - Attacker has required permissions
  - Attack path exists through actual interfaces
```

**Step 3 — Rate Exploitability:**

| Rating | Criteria |
|--------|----------|
| EASY | Public API, no special privileges, single transaction |
| MEDIUM | Multiple steps, elevated but obtainable privileges, specific state |
| HARD | Admin privileges, rare edge cases, significant resources |

**Step 4 — Build Complete Exploit Scenario:**

```
ATTACKER STARTING POSITION: [What attacker has]
STEP-BY-STEP EXPLOITATION:
  Step 1: [Action] - Command: [call] - Parameters: [values]
  Step 2: [Action] - Why: [code reference] - State change: [what changed]
  Step 3: [Impact] - Result: [concrete harm] - Evidence: [verification]
CONCRETE IMPACT: [Specific, measurable harm]
```

**Step 5 — Cross-Reference with Baseline:**

- Violates system-wide invariant?
- Breaks trust boundary?
- Bypasses validation pattern?
- Regression of previous fix?

### Phase 6: Report Generation

Mandatory report sections:

1. Executive Summary (severity table, risk assessment, recommendation)
2. What Changed (commit timeline, file summary, lines changed)
3. Critical Findings (per HIGH/CRITICAL issue with attack scenarios)
4. Test Coverage Analysis
5. Blast Radius Analysis
6. Historical Context (security-related removals, regressions)
7. Recommendations (immediate/blocking, before production, technical debt)
8. Analysis Methodology (strategy, coverage, limitations, confidence)
9. Appendices

---

## Common Vulnerability Patterns

### Security Regressions

Previously removed code re-added. Detection:

```bash
git log -S "pattern" --all --grep="security|fix|CVE"
```

Red flags: commit message contains "security", "fix", "CVE"; code removed <6 months ago; no explanation for re-addition.

### Double Decrease/Increase Bugs

Same accounting operation twice for same event. User balance decremented twice, protocol loses funds.

### Missing Validation

Removed `require`/`assert`/`check` without replacement:

```bash
git diff <range> | grep "^-.*require"
git diff <range> | grep "^-.*assert"
git diff <range> | grep "^-.*revert"
```

### Underflow/Overflow

Arithmetic without SafeMath or checks. Look for `+`, `-`, `*`, `/` in Solidity <0.8.0; `unchecked` blocks in >=0.8.0.

### Reentrancy

External call before state update (CEI violation):

```solidity
// VULNERABLE
function withdraw() {
    (bool success,) = msg.sender.call{value: amount}("");  // External call FIRST
    balances[msg.sender] = 0;  // State update AFTER
}
```

### Access Control Bypass

Removed or relaxed permission checks:

```bash
git diff <range> | grep "^-.*onlyOwner"
git diff <range> | grep "^-.*require.*msg.sender"
```

### Race Conditions / Front-Running

State-dependent logic without protection. Two-step processes without commit-reveal or timelocks.

### Timestamp Manipulation

Security logic depending on `block.timestamp`. Miners can manipulate within ~15 seconds.

### Unchecked Return Values

External call without checking success.

### Denial of Service

Unbounded loops, external call reverts blocking execution.

---

## Quality Checklist

- [ ] All changed files analyzed
- [ ] Git blame on removed security code
- [ ] Blast radius calculated for HIGH risk
- [ ] Attack scenarios are concrete (not generic)
- [ ] Findings reference specific line numbers + commits
- [ ] Report file generated
- [ ] User notified with summary

---

## Red Flags (Stop and Investigate)

- Removed code from "security", "CVE", or "fix" commits
- Access control modifiers removed (onlyOwner, internal to external)
- Validation removed without replacement
- External calls added without checks
- High blast radius (50+ callers) + HIGH risk change

---

## Report Template

```markdown
# Executive Summary

| Severity | Count |
|----------|-------|
| CRITICAL | X |
| HIGH | Y |
| MEDIUM | Z |
| LOW | W |

**Overall Risk:** CRITICAL/HIGH/MEDIUM/LOW
**Recommendation:** APPROVE/REJECT/CONDITIONAL

**Key Metrics:**
- Files analyzed: X/Y (Z%)
- Test coverage gaps: N functions
- High blast radius changes: M functions
- Security regressions detected: P
```

**File naming:** `<PROJECT>_DIFFERENTIAL_REVIEW_<DATE>.md`
