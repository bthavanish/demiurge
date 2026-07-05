# Semgrep Rule Creation Reference

## Taint Mode vs Pattern Matching

| Approach | Use When | Precision |
|----------|----------|-----------|
| **Taint mode** (prioritize) | Data flow from untrusted source to dangerous sink | High — tracks data flow |
| **Pattern matching** | Simple syntactic patterns without data flow | Lower — finds syntax but misses context |

**Why prioritize taint mode:** A pattern `eval($X)` matches both `eval(user_input)` (vulnerable) and `eval("safe_literal")` (safe). Taint mode only alerts when untrusted data actually reaches the sink.

**Iterating between approaches:** If taint mode isn't working well (taint doesn't propagate, too many FPs/FNs), switch to pattern matching. If pattern matching produces too many FPs on safe cases, try taint mode. Goal is a working rule, not rigid adherence to one approach.

## 6-Step Workflow

### Step 1: Analyze the Problem

1. Understand the exact bug pattern — what vulnerability or issue should be detected?
2. Identify the target language — what is specific about the bug and that language?
3. Determine the approach (taint mode or pattern matching)

### Step 2: Write Tests First

Create directory and test file with annotations:

```
<rule-id>/
├── <rule-id>.yaml     # Semgrep rule
└── <rule-id>.<ext>    # Test file with ruleid/ok annotations
```

Test annotations — only `# ruleid:` and `# ok:` are allowed:

```python
# ruleid: my-rule
vulnerable_code()              # This line MUST match

# ok: my-rule
safe_code()                    # This line MUST NOT match
```

**CRITICAL:**
- The comment must be on the line IMMEDIATELY BEFORE the code
- No other text on the same annotation line
- No multi-line comments for annotations (`/* ruleid: ... */` is forbidden)
- `todook` and `todoruleid` annotations are forbidden

**Test cases must include:**
- Clear vulnerable cases (must match)
- Clear safe cases (must not match)
- Edge cases and variations
- Different coding styles
- Sanitized/validated input (must not match)
- Unrelated code (must not match)
- Nested structures (inside if, loops, try/catch, callbacks)

### Step 3: Analyze AST Structure

```bash
semgrep --dump-ast --lang <language> <rule-id>.<ext>
```

Semgrep matches against the AST, not raw text. Code that looks similar may parse differently. The AST dump shows exactly what Semgrep sees.

### Step 4: Write the Rule

Validate and test:

```bash
# Validate YAML syntax
semgrep --validate --config <rule-id>.yaml

# Run tests
cd <rule-directory>
semgrep --test --config <rule-id>.yaml <rule-id>.<ext>
```

Expected output: `1/1: ✓ All tests passed`

### Step 5: Iterate Until Tests Pass

Test after every change. Debug failures:
- **Missed lines**: Pattern too specific, add pattern-either variants
- **Incorrect lines**: Pattern too broad, add pattern-not exclusions

For taint mode debugging:
```bash
semgrep --dataflow-traces --config <rule-id>.yaml <rule-id>.<ext>
```

### Step 6: Optimize the Rule

Remove redundant patterns:

| Redundancy | Before | After |
|------------|--------|-------|
| Quote variants | `hashlib.new("md5", ...)` + `hashlib.new('md5', ...)` | `hashlib.new("md5", ...)` |
| Ellipsis subsets | `dangerous($X, ...)` + `dangerous($X)` + `dangerous($X, $Y)` | `dangerous($X, ...)` |
| Similar functions | `md5($X)` + `sha1($X)` + `sha256($X)` | `$FUNC($X)` with metavariable-regex |

**Re-run tests after each optimization.** Some "redundant" patterns may be necessary due to AST structure.

## Test-First Methodology

1. Write tests BEFORE the rule — forces you to think about both vulnerable AND safe cases
2. Rules written without tests often have hidden false positives or false negatives
3. 100% test pass is required — "Most tests pass" is not acceptable

## Anti-Patterns

**Too broad:**
```yaml
# BAD: Matches any function call
pattern: $FUNC(...)

# GOOD: Specific dangerous function
pattern: eval(...)
```

**Missing safe cases in tests:**
```python
# BAD: Only tests vulnerable case
# ruleid: my-rule
dangerous(user_input)

# GOOD: Include safe cases
# ruleid: my-rule
dangerous(user_input)

# ok: my-rule
dangerous(sanitize(user_input))
```

**Overly specific patterns:**
```yaml
# BAD: Only matches exact format
pattern: os.system("rm " + $VAR)

# GOOD: Matches all os.system calls with taint tracking
mode: taint
pattern-sources:
  - pattern: input(...)
pattern-sinks:
  - pattern: os.system(...)
```

## Pattern Operators Quick Reference

### Basic Matching
```yaml
pattern: foo(...)           # Basic match
patterns:                   # Logical AND
  - pattern: $X
  - pattern-not: safe($X)
pattern-either:             # Logical OR
  - pattern: foo(...)
  - pattern: bar(...)
pattern-regex: ^foo.*bar$   # PCRE2 regex
```

### Metavariables
- `$VAR` — Match a single expression (must be uppercase)
- `$_` — Anonymous metavariable (matches but doesn't bind)
- `$...VAR` — Ellipsis metavariable (match zero or more arguments)
- `...` — Match anything in between statements/expressions
- `<... [pattern] ...>` — Deep expression operator (match nested)

### Typed Metavariables
```yaml
# Match only specific types
pattern: (int16_t $X)
pattern: ($READER : *zip.Reader).Open($INPUT)
```

### Scope Operators
```yaml
pattern-inside: |              # Must be inside this pattern
pattern-not-inside: |          # Must NOT be inside this pattern
```

### Negation
```yaml
pattern-not: safe(...)
pattern-not-regex: ^test_
```

### Metavariable Filters
```yaml
metavariable-regex:
  metavariable: $FUNC
  regex: (unsafe|dangerous).*
metavariable-comparison:
  metavariable: $NUM
  comparison: $NUM > 1024
```

## Taint Mode Syntax

```yaml
mode: taint
pattern-sources:
  - pattern: user_input()
  - pattern: request.args.get(...)
pattern-sinks:
  - pattern: eval(...)
  - pattern: os.system(...)
pattern-sanitizers:
  - pattern: sanitize(...)
  - pattern: escape(...)
```

**Taint options:**
```yaml
pattern-sources:
  - pattern: source(...)
    exact: true                   # Only exact match is source
    by-side-effect: true          # Taints by side effect
pattern-sinks:
  - pattern: sink(...)
    exact: false                  # Subexpressions also sinks
```

## Debugging Commands

```bash
semgrep --test --config <rule-id>.yaml <rule-id>.<ext>    # Test rules
semgrep --validate --config <rule-id>.yaml                 # Validate YAML
semgrep --dataflow-traces --config <rule-id>.yaml <file>   # Taint traces
semgrep --dump-ast --lang <language> <file>                # AST dump
semgrep --config <rule-id>.yaml <file>                     # Run single rule
semgrep --lang <language> --pattern <pattern> <file>       # Run single pattern
```

## Common Fixes

| Problem | Solution |
|---------|----------|
| Too many matches | Add `pattern-not` exclusions |
| Missing matches | Add `pattern-either` variants |
| Wrong line matched | Adjust `focus-metavariable` |
| Taint not flowing | Check sanitizers aren't too broad |
| Taint false positive | Add sanitizer pattern |

## Strictness Rules

- Test-first is mandatory — never write a rule without tests
- 100% test pass is required
- One YAML file = one Semgrep rule
- No generic rules (`languages: generic`) when targeting a specific language
- No `todook` or `todoruleid` test annotations
- Optimization comes last — only simplify after all tests pass
