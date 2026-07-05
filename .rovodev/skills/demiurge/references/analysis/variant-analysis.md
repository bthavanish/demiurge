# Variant Analysis Reference

## 5-Step Process

### Step 1: Understand the Original Issue

Before searching, deeply understand the known bug:
- **Root cause**: Not the symptom, but WHY it's vulnerable
- **Required conditions**: Control flow, data flow, state
- **Exploitability**: User control, missing validation, etc.

**Root cause statement:**
> "This vulnerability exists because [UNTRUSTED DATA] reaches [DANGEROUS OPERATION] without [REQUIRED PROTECTION]."

### Step 2: Create an Exact Match

Start with a pattern that matches ONLY the known instance:
```bash
rg -n "exact_vulnerable_code_here"
```

Verify: Does it match exactly ONE location (the original)?

### Step 3: Identify Abstraction Points

| Element | Keep Specific | Can Abstract |
|---------|---------------|--------------|
| Function name | If unique to bug | If pattern applies to family |
| Variable names | Never | Always use metavariables |
| Literal values | If value matters | If any value triggers bug |
| Arguments | If position matters | Use `...` wildcards |

### Step 4: Iteratively Generalize

**Change ONE element at a time:**
1. Run the pattern
2. Review ALL new matches
3. Classify: true positive or false positive?
4. If FP rate acceptable, generalize next element
5. If FP rate too high, revert and try different abstraction

**Stop when false positive rate exceeds ~50%**

### Step 5: Analyze and Triage Results

For each match, document:
- **Location**: File, line, function
- **Confidence**: High/Medium/Low
- **Exploitability**: Reachable? Controllable inputs?
- **Priority**: Based on impact and exploitability

## Abstraction Ladder

Patterns exist at different levels. Start at Level 0 and climb.

| Level | Pattern | Matches | False Positives | Use Case |
|-------|---------|---------|-----------------|----------|
| 0: Exact Match | Literal vulnerable code | 1 | 0 | Verify specific fix |
| 1: Variable Abstraction | Replace variable names with wildcards | 3-5 | Low | Find copy-paste variants |
| 2: Structural Abstraction | Generalize structure | 10-30 | Medium | Audit a component |
| 3: Semantic Abstraction | Taint mode (any source to any sink) | 50-100+ | High | Full security assessment |

### Generalization Rule: One Change at a Time

```
BAD:  exact code -> fully abstract pattern
GOOD: exact code -> abstract var1 -> abstract var2 -> abstract operation
```

## CodeQL Query Templates

### Python Template

```ql
/**
 * @name [VARIANT_NAME]
 * @description Find variants of [ORIGINAL_BUG_ID]
 * @kind path-problem
 * @problem.severity error
 * @precision high
 * @tags security variant-analysis
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import semmle.python.ApiGraphs

module VariantConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    // Flask request parameters
    source = API::moduleImport("flask").getMember("request")
             .getMember(["args", "form", "json", "data"])
             .getAUse()
    or
    // Environment variables
    exists(Call c |
      c.getFunc().(Attribute).getObject().(Name).getId() = "os" and
      c.getFunc().(Attribute).getName() in ["getenv", "environ"] and
      source.asExpr() = c
    )
  }

  predicate isSink(DataFlow::Node sink) {
    // os.system()
    exists(Call c |
      c.getFunc().(Attribute).getObject().(Name).getId() = "os" and
      c.getFunc().(Attribute).getName() = "system" and
      sink.asExpr() = c.getArg(0)
    )
    or
    // subprocess with shell=True
    exists(Call c |
      c.getFunc().(Attribute).getName() in ["call", "run", "Popen"] and
      c.getArgByName("shell").(NameConstant).getValue() = true and
      sink.asExpr() = c.getArg(0)
    )
  }

  predicate isBarrier(DataFlow::Node node) {
    exists(Call c |
      c.getFunc().(Attribute).getObject().(Name).getId() = "shlex" and
      c.getFunc().(Attribute).getName() = "quote" and
      node.asExpr() = c
    )
  }
}

module VariantFlow = TaintTracking::Global<VariantConfig>;
import VariantFlow::PathGraph

from VariantFlow::PathNode source, VariantFlow::PathNode sink
where VariantFlow::flowPath(source, sink)
select sink.getNode(), source, sink,
  "Potential variant: tainted data from $@ flows to dangerous sink.",
  source.getNode(), "user-controlled input"
```

### Go Template

```ql
/**
 * @name [VARIANT_NAME]
 * @description Find variants of [ORIGINAL_BUG_ID]
 * @kind path-problem
 * @problem.severity error
 * @tags security variant-analysis
 */

import go
import semmle.go.dataflow.TaintTracking
import DataFlow::PathGraph

module VariantConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    exists(DataFlow::CallNode c |
      c.getTarget().hasQualifiedName("net/http", "Request", ["FormValue", "PostFormValue"]) and
      source = c.getResult()
    )
  }

  predicate isSink(DataFlow::Node sink) {
    exists(DataFlow::CallNode c |
      c.getTarget().hasQualifiedName("os/exec", "Command") and
      sink = c.getArgument(0)
    )
  }

  predicate isBarrier(DataFlow::Node node) {
    exists(DataFlow::CallNode c |
      c.getTarget().getName() in ["Escape", "Quote", "Clean"] and
      node = c.getResult()
    )
  }
}

module VariantFlow = TaintTracking::Global<VariantConfig>;
import VariantFlow::PathGraph

from VariantFlow::PathNode source, VariantFlow::PathNode sink
where VariantFlow::flowPath(source, sink)
select sink.getNode(), source, sink,
  "Tainted data from $@ flows to dangerous sink.",
  source.getNode(), "user input"
```

## Semgrep Query Templates

### Python Taint Template

```yaml
rules:
  - id: variant-taint-analysis
    message: >-
      Potential variant: user-controlled data flows to dangerous sink.
      Original bug: [DESCRIBE_ORIGINAL_BUG]
    severity: ERROR
    languages: [python]
    mode: taint

    pattern-sources:
      - pattern: request.args.get(...)
      - pattern: request.form.get(...)
      - pattern: os.environ.get(...)
      - pattern: input(...)

    pattern-sinks:
      - pattern: os.system($SINK)
      - pattern: subprocess.call($SINK, ...)
      - pattern: eval($SINK)

    pattern-sanitizers:
      - pattern: shlex.quote(...)
      - pattern: int(...)
      - pattern: sanitize(...)

    paths:
      exclude:
        - "*_test.py"
        - "tests/"
```

## FP Management

### Acceptable FP Rates by Context

| Context | Acceptable FP Rate |
|---------|-------------------|
| Automated CI blocking | <5% |
| Developer warning | <20% |
| Security audit triage | <50% |
| Research/exploration | <80% |

### Common FP Sources and Filters

**Dead code:** Add reachability constraints
```yaml
pattern-not-inside: |
  if False:
    ...
```

**Test code:** Exclude test directories

**Already sanitized:** Add sanitizer patterns
```yaml
pattern-not: dangerous_func(sanitize($X))
```

**Literal values:** Exclude non-user-controlled data
```yaml
pattern-not: dangerous_func("...")
```

## Critical Pitfalls

### 1. Narrow Search Scope
Searching only the module where the original bug was found misses variants elsewhere. Always search the ENTIRE codebase.

### 2. Pattern Too Specific
Using only the exact attribute/function from the original bug misses related constructs. Enumerate ALL semantically related attributes/functions.

### 3. Single Vulnerability Class
Focusing on only one manifestation misses other ways the same logic error appears. List all possible manifestations before searching.

### 4. Missing Edge Cases
Testing patterns only with "normal" scenarios misses vulnerabilities triggered by edge cases (null, undefined, empty collections, boundary conditions).

## Tool Selection

| Scenario | Tool | Why |
|----------|------|-----|
| Quick surface search | ripgrep | Fast, zero setup |
| Simple pattern matching | Semgrep | Easy syntax, no build needed |
| Data flow tracking | Semgrep taint / CodeQL | Follows values across functions |
| Cross-function analysis | CodeQL | Best interprocedural analysis |

## Multi-Repository Campaign

**Recon** (ripgrep to find hotspots) → **Deep Analysis** (Semgrep/CodeQL on hotspots) → **Refinement** (reduce FPs) → **Automation** (CI-ready rules).

## Expanding Vulnerability Classes

For each root cause, ask:
1. What other attributes/functions have similar semantics?
2. What other boolean logic errors could occur?
3. What edge cases exist for the data types involved?
4. What documentation mismatches could exist?

## Tracking Document Template

```markdown
## Variant Analysis: [Original Bug ID]

### Root Cause
[Statement of the vulnerability pattern]

### Patterns Tried
| Pattern | Level | Matches | True Pos | False Pos | Notes |
|---------|-------|---------|----------|-----------|-------|
| exact   | 0     | 1       | 1        | 0         | Baseline |

### Confirmed Variants
| Location | Severity | Status | Notes |
|----------|----------|--------|-------|
| file:line| High     | Fixed  | ...   |

### False Positive Patterns
- Pattern X: Always FP because [reason]
```
