# False Positive Verification

Methodology for verifying whether reported bugs are true positives or false positives. Covers standard vs deep verification paths, 6 mandatory gates, 13 FP patterns, bug-class-specific verification, and evidence templates.

---

## Verification Paths

### Standard Verification

Linear single-pass checklist for straightforward bugs. No task tracking — work through each step sequentially.

**Escalation checkpoints:**

1. **After Step 1 (Data Flow)**: Escalate if 3+ trust boundaries, callbacks/async control flow, or ambiguous validation chain
2. **After Step 5 (Devil's Advocate)**: Escalate if any question produces genuine uncertainty

When escalating, hand off all evidence gathered so far — deep verification continues from where you left off.

### Deep Verification

Full task-based verification for complex bugs. Creates one task per phase with dependency structure:

```
Phase 1: Data Flow Analysis
  1.1 Map trust boundaries and trace data flow
  1.2 Research API contracts and safety guarantees (parallel with 1.3, 1.4)
  1.3 Environment protection analysis
  1.4 Cross-reference analysis

Phase 2: Exploitability Verification (blocked by Phase 1)
  2.1 Confirm attacker controls input data (parallel)
  2.2 Mathematical bounds verification
  2.3 Race condition feasibility proof
  2.4 Adversarial analysis (blocked by 2.1-2.3)

Phase 3: Impact Assessment (blocked by Phase 2)
  3.1 Demonstrate real security impact (parallel)
  3.2 Primary control vs defense-in-depth

Phase 4: PoC Creation (blocked by Phase 3)
  4.1 Create pseudocode PoC with data flow diagrams
  4.2 Create executable PoC if feasible (parallel, blocked by 4.1)
  4.3 Create unit test PoC if feasible
  4.4 Negative PoC — show exploit preconditions
  4.5 Verify PoC demonstrates the vulnerability (blocked by 4.2-4.4)

Phase 5: Devil's Advocate (blocked by Phase 4)
  5.1 Devil's advocate review

Gate Review (blocked by Phase 5)
  Evaluate all six gates before verdict
```

---

## 6 Mandatory Gates

All six must pass before reporting a bug as a true positive:

| Gate | Criterion | Pass | Fail |
|------|-----------|------|------|
| **1. Process** | All phases completed with documented evidence | Evidence exists for every phase | Phases lack concrete evidence |
| **2. Reachability** | Attacker can reach and control data at the vulnerability | Clear evidence of attacker-controlled path + PoC confirms | Cannot demonstrate attacker control or reachability |
| **3. Real Impact** | Exploitation leads to RCE, privesc, or info disclosure | Direct impact with concrete scenarios | Only operational robustness issue |
| **4. PoC Validation** | PoC demonstrates the attack path | Shows attacker control, trigger, and impact | PoC fails to show attack path or impact |
| **5. Math Bounds** | Mathematical analysis confirms vulnerable condition is possible | Algebraic proof shows condition is possible | Math proves validation prevents it |
| **6. Environment** | No environmental protections entirely prevent exploitation | Protections do not eliminate vulnerability | Environmental protections block it entirely |

### Verdict Format

- **TRUE POSITIVE**: All gates pass -> `BUG #N TRUE POSITIVE — [brief description]`
- **FALSE POSITIVE**: Any gate fails -> `BUG #N FALSE POSITIVE — [brief reason]`

---

## 13 False Positive Patterns

Apply ALL items to EACH potential bug:

### 1. Trace Full Validation Chain

Don't analyze isolated code snippets. Trace backwards to find ALL validation preceding dangerous operations.

### 1a. Map Complete Conditional Logic Flow

Vulnerable-looking code may be unreachable due to conditional logic creating mathematical guarantees.

**Verify:**
- What conditions must be met to reach the alleged vulnerability?
- Do those conditions mathematically prevent the vulnerability?
- Are there minimum size/length requirements that guarantee safe access?

### 2. Identify Defensive Programming Patterns

Distinguish between actual vulnerabilities and defensive assertions. `ASSERT(size == expected_size)` followed by size-controlled operations is defensive, not vulnerable.

### 3. Confirm Exploitable Data Paths

Only report vulnerabilities with CONFIRMED exploitable data flow paths. Don't assume network-controlled data reaches dangerous functions without tracing step by step.

### 4. Understand Data Source Context

Distinguish between data sources and trust levels. API return values, compile-time constants, and network data have different risk profiles.

### 5. Analyze Bounds Validation Logic

Look for mathematical relationships between validation checks and subsequent operations. If `packet_size >= MIN_SIZE` is checked and `MIN_SIZE >= sizeof(header)`, then `packet_size - sizeof(header)` cannot underflow.

### 6. Verify TOCTOU Claims

TOCTOU requires proof that the checked value can change between check and use. If checked and immediately used with no external modification possible, there is no TOCTOU.

### 7. Understand API Contract and Trust Boundaries

Some APIs have built-in bounds protection and cannot write beyond the buffer regardless of input parameters.

### 8. Distinguish Internal Storage from External Input

Internal storage systems (configuration stores, registries) are controlled by trusted components, not attackers.

### 9. Don't Confuse Pattern Recognition with Vulnerability Analysis

Code patterns that "look vulnerable" may be safely implemented due to context and API contracts.

### 10. Verify Concurrent Access is Actually Possible

Single-threaded initialization contexts cannot have race conditions. Verify the threading model and synchronization mechanisms.

### 11. Assess Real vs Theoretical Security Impact

Focus on vulnerabilities with actual security impact. Storage failure for non-critical data is an operational issue, not security.

### 12. Understand Defense-in-Depth vs Primary Controls

Failure of defense-in-depth mechanisms is not always a vulnerability if primary protections exist.

### 13. Apply the Checklist Rigorously, Not Superficially

For EVERY potential vulnerability, work through ALL checklist items before concluding.

---

## Red Flags for False Positives

### Pattern-Based

- Reporting vulnerabilities in validation/bounds-checking code itself
- Claiming TOCTOU without proving the value can change
- Ignoring preceding validation logic
- Assuming network data reaches operations without tracing the path
- Confusing defensive programming with vulnerabilities
- Analyzing vulnerable-looking patterns without tracing conditional logic
- Reporting "vulnerabilities" in error handling or cleanup code
- Flagging size calculations without understanding mathematical constraints
- Identifying "dangerous" functions without checking if inputs are bounded
- Claiming buffer overflows in fixed-size operations with compile-time bounds
- Reporting race conditions in single-threaded or synchronized contexts

### Context-Blind Analysis

- Analyzing code snippets without understanding broader system design
- Ignoring architectural guarantees (single-writer, trusted input sources)
- Missing that "vulnerable" code is unreachable due to earlier validation
- Confusing debug/development code paths with production paths
- Reporting issues in code that only runs during trusted installation/setup
- Flagging theoretical issues prevented by framework or language guarantees
- Reporting issues in test-only or debug-only code paths

### Mathematical/Bounds Analysis

- Reporting integer underflow without proving the mathematical condition can occur
- Claiming buffer overflow when bounds are mathematically guaranteed by validation
- Missing that conditional logic creates mathematical impossibility
- Reporting off-by-one errors without checking if loop bounds prevent the condition
- Claiming memory corruption when allocation sizes are verified sufficient
- Reporting arithmetic overflow without checking if input ranges prevent the condition

### API Contract Misunderstanding

- Claiming buffer overflows when APIs have built-in bounds checking
- Reporting memory corruption for APIs that manage their own memory safely
- Missing that return values are already validated by the API contract
- Confusing API parameter modification with vulnerability when API prevents unsafe modification
- Reporting issues explicitly handled by the API's safety guarantees

---

## Bug-Class-Specific Verification

### Memory Corruption

- Language safety check first: memory corruption in safe Rust, Go (without unsafe.Pointer), or managed languages is almost always FP
- What exactly gets corrupted? Is it a useful exploitation primitive?
- What allocator is in use? Does it have hardening?
- For UAF: trace object lifetime
- For type confusion: prove type mismatch exists and leads to a primitive

### Logic Bugs

- Check against specification/RFC/design docs, not just code
- Map all state transitions — can the system reach an unanticipated state?
- For auth bugs: verify ALL authentication/authorization paths

### Race Conditions

- What is the actual race window? Nanoseconds or seconds?
- Can the attacker widen the window?
- Verify threading model — what threads can actually access this data concurrently?
- For TOCTOU: can the attacker control the path between check and use?

### Integer Issues

- What are exact integer types and ranges at every computation point?
- Is overflow signed (UB in C/C++) or unsigned (defined wraparound)?
- Trace integer through all casts, conversions, and promotions
- After overflow, is the resulting value used in a dangerous way?

### Crypto Weaknesses

- Check parameter choices against current standards
- Verify randomness sources — cryptographically secure, properly seeded?
- For timing side channels: is code actually reachable by attacker who can measure timing?

### Injection

- Trace attacker input from entry point to sink — any sanitization?
- Check if framework provides automatic escaping
- For XSS: what context does input land in?
- For path traversal: is path canonicalized before access check?

### Information Disclosure

- What specific data leaks? ASLR base is critical; static string is worthless
- Is leaked data useful for further exploitation?
- For timing: can attacker make enough measurements with sufficient precision?

### Denial of Service

- Resource consumption ratio: attacker sends X, server consumes Y
- For algorithmic complexity: prove worst-case input triggers it
- For crashes: reliably triggerable or dependent on heap/stack layout?

### Deserialization

- Does attacker control serialized data reaching deserialization call?
- Does a usable gadget chain exist in classpath/import graph?
- What library/version in use? Known gadget chains?

---

## Evidence Templates

### Data Flow Documentation

```
Bug #N Data Flow Analysis
Source: [exact location] — Trust Level: [trusted/untrusted]
Path: Source -> Validation1[file:line] -> Transform[file:line] -> Vulnerability[file:line]
Validation Points:
  - Check1: [condition] at [file:line] — [passes/fails/bypassed]
  - Check2: [condition] at [file:line] — [passes/fails/bypassed]
```

### Mathematical Bounds Proof

```
Bug #N Mathematical Analysis
Claim: Operation X is vulnerable to [overflow/underflow/bounds violation]
Given Constraints: [list all validation conditions]

Algebraic Proof:
1. [first constraint from validation]
2. [constant or known value]
3. [derived inequality]
...
N. Therefore: [vulnerability confirmed/debunked] (Q.E.D.)
```

### PoC Template

```
PoC for Bug #N: [Brief Description]

Data Flow Diagram:
[External Input] -> [Validation Point] -> [Processing] -> [Vulnerable Operation]

PSEUDOCODE:
function vulnerable_operation(user_data):
    validation_result = weak_validation(user_data)
    processed_data = transform_data(user_data)
    unsafe_operation(processed_data)
```

### Devil's Advocate Review

```
Bug #N Devil's Advocate Review
Vulnerability Claim: [brief description]

1-11. Challenges arguing AGAINST the vulnerability
12-13. Challenges arguing FOR the vulnerability (false-negative protection)

Final Assessment: [Vulnerability confirmed/debunked with reasoning]
```
