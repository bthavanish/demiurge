# Spec-to-Code Compliance Reference

## 7-Phase Workflow

### Phase 0: Documentation Discovery

Identify all content representing documentation, even if not named "spec":
- whitepapers, design documents, README
- kickoff transcripts, Notion exports
- Anything describing logic, flows, assumptions, incentives

Extract semantic cues: architecture descriptions, invariants, formulas, variable meanings, trust models, workflow sequencing, tables, diagrams.

### Phase 1: Universal Format Normalization

Normalize any input format (PDF, Markdown, DOCX, HTML, TXT, transcripts) into a clean canonical spec corpus. Preserve heading hierarchy, bullet lists, formulas, tables, code snippets, invariant definitions. Remove layout noise, styling artifacts, watermarks.

### Phase 2: Spec Intent IR (Intermediate Representation)

Extract all intended behavior into Spec-IR. Each item must include:
- `spec_excerpt`
- `source_section`
- `semantic_type`
- normalized representation
- confidence score

Extract: protocol purpose, actors/roles/trust boundaries, variable definitions, preconditions/postconditions, explicit/implicit invariants, math formulas, expected flows, economic assumptions, ordering constraints, error conditions, security requirements (MUST/NEVER/ALWAYS), edge-case behavior.

### Phase 3: Code Behavior IR

Perform line-by-line and block-by-block semantic analysis of the entire codebase.

For EVERY LINE and EVERY BLOCK, extract:
- file + exact line numbers
- local variable updates, state reads/writes
- conditional branches & alternative paths
- revert conditions & custom errors
- external calls (call, delegatecall, staticcall, create2)
- event emissions, math operations, rounding behavior
- implicit assumptions
- block-level preconditions & postconditions
- locally enforced invariants, state transitions, side effects
- dependencies on prior state

For EVERY FUNCTION, extract:
- signature & visibility, applied modifiers
- purpose, input/output semantics
- read/write sets, full control-flow structure
- success vs revert paths
- internal/external call graph, cross-function interactions

Also capture: storage layout, initialization logic, authorization graph, upgradeability mechanism, hidden assumptions.

### Phase 4: Alignment IR (Spec ↔ Code Comparison)

For each item in Spec-IR, locate related behaviors in Code-IR and generate an Alignment Record:

- `spec_excerpt` / `code_excerpt` (with file + line numbers)
- `match_type` (one of 6 types)
- `reasoning trace`
- `confidence score (0-1)`
- `ambiguity rating`
- `evidence links`

Explicitly check: invariants vs enforcement, formulas vs math implementation, flows vs real transitions, actor expectations vs privilege map, ordering constraints vs actual logic, revert expectations vs actual checks, trust assumptions vs external call behavior.

Also detect: undocumented code behavior, unimplemented spec claims, contradictions in spec or code, inconsistencies across spec documents.

### Phase 5: Divergence Classification

| Severity | Description |
|----------|-------------|
| **CRITICAL** | Spec says X, code does Y; missing invariant enabling exploits; math divergence involving funds; trust boundary mismatches |
| **HIGH** | Partial/incorrect implementation; access control misalignment; dangerous undocumented behavior |
| **MEDIUM** | Ambiguity with security implications; missing revert checks; incomplete edge-case handling |
| **LOW** | Documentation drift; minor semantics mismatch |

### Phase 6: Final Audit-Grade Report

Produce a structured compliance report with 16 sections:
1. Executive Summary
2. Documentation Sources Identified
3. Spec Intent Breakdown (Spec-IR)
4. Code Behavior Summary (Code-IR)
5. Full Alignment Matrix (Spec → Code → Status)
6. Divergence Findings (with evidence & severity)
7. Missing invariants
8. Incorrect logic
9. Math inconsistencies
10. Flow/state machine mismatches
11. Access control drift
12. Undocumented behavior
13. Ambiguity hotspots (spec & code)
14. Recommended remediations
15. Documentation update suggestions
16. Final risk assessment

## IR System

### Spec-IR Record Format

```yaml
id: SPEC-001
spec_excerpt: "All swaps MUST enforce maximum slippage of 1%"
source_section: "Whitepaper §4.1 - Trading Mechanism"
source_document: "dex-protocol-whitepaper-v3.pdf"
semantic_type: invariant
normalized_form:
  type: constraint
  entity: swap_transaction
  operation: token_exchange
  condition: "abs((actual_output - expected_output) / expected_output) <= 0.01"
  enforcement: MUST (mandatory)
confidence: 1.0
```

### Code-IR Record Format

```yaml
id: CODE-001
file: "contracts/Router.sol"
function: "swap(address tokenIn, address tokenOut, uint256 amountIn, uint256 minAmountOut, uint256 deadline)"
lines: 89-135
visibility: external
modifiers: [nonReentrant, ensure(deadline)]

behavior:
  preconditions:
    - condition: "block.timestamp <= deadline"
      line: 90
      enforcement: modifier (ensure)
  state_reads:
    - variable: "pairs[tokenIn][tokenOut]"
      line: 98
  state_writes:
    - variable: "reserves[pair].reserve0"
      line: 125
  computations:
    - operation: "amountInWithFee = amountIn * 997"
      line: 108
  external_calls:
    - target: "IERC20(tokenIn).transferFrom(msg.sender, pair, amountIn)"
      line: 118
  events:
    - name: "Swap"
      line: 130
  postconditions:
    - "amountOut >= minAmountOut"

invariants_enforced:
  - "slippage_protection: amountOut >= minAmountOut (line 115)"
  - "constant_product: reserveIn * reserveOut >= k_before (line 125-126)"
```

### Alignment-IR Record Format

```yaml
id: ALIGN-001
spec_ref: SPEC-001
code_ref: CODE-001
spec_claim: "Protocol MUST charge exactly 0.3% fee on all swaps"
code_behavior: "amountInWithFee = amountIn * 997 (line 108), effective fee = 0.3%"
match_type: full_match
confidence: 1.0
reasoning: |
  Spec requires: 0.3% fee on all swaps
  Code implements: amountIn * 997 / 1000
  Mathematical verification: 3 / 1000 = 0.3% ✓
evidence:
  spec_quote: "The protocol charges a fixed 0.3% fee"
  code_quote: "uint256 amountInWithFee = amountIn * 997;"
```

## Match Types

| Match Type | Meaning |
|------------|---------|
| `full_match` | Code implements exactly what spec requires |
| `partial_match` | Code partially implements spec — investigate further |
| `mismatch` | Spec says X, code does Y |
| `missing_in_code` | Spec requirement has no corresponding code |
| `code_stronger_than_spec` | Code has additional protections not in spec |
| `code_weaker_than_spec` | Code implementation is weaker than spec requirement |

## Divergence Classification

Each finding MUST include:
- `id`, `severity`, `title`
- `spec_claim` with excerpt and source
- `code_finding` with file, function, lines, observation
- `match_type`, `confidence`
- `reasoning` trace
- `evidence` with exact quotes and locations
- `exploitability` analysis with attack scenarios (prerequisites, sequence, impact)
- `remediation` with code examples, testing requirements, breaking changes

## Completeness Verification

### Spec-IR Completeness
- [ ] ALL explicit invariants extracted
- [ ] ALL implicit invariants deduced
- [ ] ALL formulas and mathematical relationships
- [ ] ALL actor definitions, roles, trust boundaries
- [ ] ALL state machine transitions and workflows
- [ ] ALL security requirements (MUST/NEVER/ALWAYS)
- [ ] ALL preconditions and postconditions
- [ ] Every item has `source_section` citation and confidence score

### Code-IR Completeness
- [ ] ALL public and external functions analyzed
- [ ] ALL internal functions called by public/external functions
- [ ] ALL state reads/writes documented with line numbers
- [ ] ALL external calls documented with return handling
- [ ] ALL revert conditions documented
- [ ] ALL modifiers documented
- [ ] Minimum 3 invariants per function

### Alignment-IR Completeness
- [ ] EVERY Spec-IR item has Alignment record
- [ ] EVERY record has match_type classification
- [ ] EVERY match_type has reasoning
- [ ] EVERY record has evidence with exact quotes
- [ ] EVERY divergence has Divergence Finding
- [ ] Undocumented code behavior flagged
- [ ] Ambiguities classified (not guessed)

### Divergence Finding Quality
- [ ] EVERY CRITICAL/HIGH finding has exploit scenario
- [ ] Economic impact quantified with concrete numbers
- [ ] Remediation includes code examples
- [ ] Testing requirements specified
- [ ] Breaking changes documented with migration path

## Anti-Hallucination Requirements

- If the spec is silent: classify as **UNDOCUMENTED**
- If the code adds behavior: classify as **UNDOCUMENTED CODE PATH**
- If unclear: classify as **AMBIGUOUS**
- Every claim must quote original text or line numbers
- Zero speculation
- Exhaustive, literal, pedantic reasoning
- Every claim must have confidence score (0-1)
- Confidence < 0.8 requires ambiguity documentation

## Global Rules

- Never infer unspecified behavior
- Always cite exact evidence from documentation (section/title/quote) and code (file + line numbers)
- Always provide confidence score for mappings
- Always classify ambiguity instead of guessing
- Maintain strict separation: extraction → alignment → classification → reporting
- Do NOT rely on prior knowledge of known protocols — only use provided materials
