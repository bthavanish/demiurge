# Audit Context Building Reference

## Purpose

Ultra-granular, line-by-line code analysis to build deep architectural context before vulnerability or bug finding. This is **pure context building** — no vulnerabilities, fixes, exploits, or severity ratings.

## 3-Phase Process

### Phase 1: Initial Orientation (Bottom-Up Scan)

Before deep analysis, perform minimal mapping:

1. Identify major modules/files/contracts
2. Note obvious public/external entrypoints
3. Identify likely actors (users, owners, relayers, oracles, other contracts)
4. Identify important storage variables, dicts, state structs, or cells
5. Build preliminary structure without assuming behavior

### Phase 2: Ultra-Granular Function Analysis (Default Mode)

Every non-trivial function receives full micro analysis. See [Per-Function Micro-Analysis](#per-function-micro-analysis) below.

### Phase 3: Global System Understanding

After sufficient micro-analysis:

1. **State & Invariant Reconstruction**
   - Map reads/writes of each state variable
   - Derive multi-function and multi-module invariants

2. **Workflow Reconstruction**
   - Identify end-to-end flows (deposit, withdraw, lifecycle, upgrades)
   - Track how state transforms across these flows
   - Record assumptions that persist across steps

3. **Trust Boundary Mapping**
   - Actor → entrypoint → behavior
   - Identify untrusted input paths
   - Privilege changes and implicit role expectations

4. **Complexity & Fragility Clustering**
   - Functions with many assumptions
   - High branching logic
   - Multi-step dependencies
   - Coupled state changes across modules

## Per-Function Micro-Analysis

### Per-Function Microstructure Checklist

For each function:

1. **Purpose** — Why the function exists and its role in the system
2. **Inputs & Assumptions** — Parameters, implicit inputs (state, sender, env), preconditions, constraints
3. **Outputs & Effects** — Return values, state/storage writes, events/messages, external interactions
4. **Block-by-Block / Line-by-Block Analysis** — For each logical block:
   - What it does
   - Why it appears here (ordering logic)
   - What assumptions it relies on
   - What invariants it establishes or maintains
   - What later logic depends on it
   - Apply: First Principles, 5 Whys, 5 Hows

### Cross-Function & External Flow Analysis

**Internal Calls:**
- Jump into the callee immediately
- Perform block-by-block analysis of relevant code
- Track flow of data, assumptions, and invariants: caller → callee → return → caller

**External Calls (code exists in codebase):**
- Treat as internal call — jump into target contract/function
- Continue block-by-block micro-analysis

**External Calls (no code available):**
Analyze as adversarial:
- Describe payload/value/gas or parameters sent
- Identify assumptions about the target
- Consider all outcomes: revert, incorrect returns, unexpected state changes, misbehavior, reentrancy

**Continuity Rule:** Treat the entire call chain as one continuous execution flow. Never reset context. All invariants, assumptions, and data dependencies must propagate across calls.

## Output Requirements

For EACH analyzed function, output MUST include:

**1. Purpose** (mandatory)
- Clear statement of function's role in the system
- Impact on system state, security, or economics
- Minimum 2-3 sentences

**2. Inputs & Assumptions** (mandatory)
- All parameters (explicit and implicit)
- All preconditions
- All trust assumptions
- Each input must identify: type, source, trust level
- Minimum 3 assumptions documented

**3. Outputs & Effects** (mandatory)
- Return values (or "void" if none)
- All state writes
- All external interactions
- All events emitted
- All postconditions
- Minimum 3 effects documented

**4. Block-by-Block Analysis** (mandatory)
For EACH logical code block:
- **What:** What the block does (1 sentence)
- **Why here:** Why this ordering/placement (1 sentence)
- **Assumptions:** What must be true (1+ items)
- **Depends on:** What prior state/logic this relies on
- **First Principles / 5 Whys / 5 Hows:** Apply at least ONE per block

**5. Cross-Function Dependencies** (mandatory)
- Internal calls made (list all)
- External calls made (list all with risk analysis)
- Functions that call this function
- Shared state with other functions
- Invariant couplings
- Minimum 3 dependency relationships documented

### Quality Thresholds

- Minimum 3 invariants per function
- Minimum 5 assumptions documented
- Minimum 3 risk considerations for external interactions
- At least 1 First Principles application
- At least 3 combined 5 Whys/5 Hows applications

## Completeness Checklist

Before concluding micro-analysis of a function, verify:

### Structural Completeness
- [ ] Purpose section: 2+ sentences explaining function role
- [ ] Inputs & Assumptions section: All parameters + implicit inputs documented
- [ ] Outputs & Effects section: All returns, state writes, external calls, events
- [ ] Block-by-Block Analysis: Every logical block analyzed (no gaps)
- [ ] Cross-Function Dependencies: All calls and shared state documented

### Content Depth
- [ ] Identified at least 3 invariants
- [ ] Documented at least 5 assumptions
- [ ] Applied First Principles at least once
- [ ] Applied 5 Whys or 5 Hows at least 3 times total
- [ ] Risk analysis for all external interactions

### Continuity & Integration
- [ ] Cross-reference with related functions
- [ ] Propagated assumptions from callers
- [ ] Identified invariant couplings
- [ ] Tracked data flow across function boundaries

### Anti-Hallucination Verification
- [ ] All claims reference specific line numbers (L45, L98-102, etc.)
- [ ] No vague statements ("probably", "might", "seems to") — replaced with "unclear; need to check X"
- [ ] Contradictions resolved (if earlier analysis conflicts, explicitly updated)
- [ ] Evidence-based: Every invariant/assumption tied to actual code

### Completeness Signal

Analysis is complete when:
1. All checklist items above are satisfied
2. No remaining "TODO: analyze X" or "unclear Y" items
3. Full call chain analyzed (for internal calls, jumped into and analyzed)
4. All identified risks have mitigation analysis or acknowledged as unresolved

## Anti-Hallucination Rules

- **Never reshape evidence to fit earlier assumptions.** When contradicted: update the model, state the correction explicitly.
- **Periodically anchor key facts.** Summarize core invariants, state relationships, actor roles, workflows.
- **Avoid vague guesses.** Use "Unclear; need to inspect X." instead of "It probably…"
- **Cross-reference constantly.** Connect new insights to previous state, flows, and invariants.

## Rationalizations to Skip

| Rationalization | Why It's Wrong | Required Action |
|-----------------|----------------|-----------------|
| "I get the gist" | Gist-level understanding misses edge cases | Line-by-line analysis required |
| "This function is simple" | Simple functions compose into complex bugs | Apply 5 Whys anyway |
| "I'll remember this invariant" | You won't. Context degrades. | Write it down explicitly |
| "External call is probably fine" | External = adversarial until proven otherwise | Jump into code or model as hostile |
| "I can skip this helper" | Helpers contain assumptions that propagate | Trace the full call chain |
| "This is taking too long" | Rushed context = hallucinated vulnerabilities later | Slow is fast |

## When to Use

- Deep comprehension is needed before bug or vulnerability discovery
- Bottom-up understanding instead of high-level guessing
- Reducing hallucinations, contradictions, and context loss is critical
- Preparing for security auditing, architecture review, or threat modeling

## When NOT to Use

- Vulnerability findings
- Fix recommendations
- Exploit reasoning
- Severity/impact rating
