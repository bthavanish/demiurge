# Static Analysis Reference

## Variant Analysis

Find variants of a known vulnerability across a codebase.

### 5-Step Process

1. **Understand the original issue.** Root cause (not symptom), required conditions, exploitability.
   > "This vulnerability exists because [UNTRUSTED DATA] reaches [DANGEROUS OPERATION] without [REQUIRED PROTECTION]."

2. **Create an exact match.** `rg -n "exact_vulnerable_code_here"` -- verify it matches ONLY the original.

3. **Identify abstraction points.**

   | Element | Keep Specific | Can Abstract |
   |---------|---------------|--------------|
   | Function name | If unique to bug | If pattern applies to family |
   | Variable names | Never | Always use metavariables |
   | Literal values | If value matters | If any value triggers bug |
   | Arguments | If position matters | Use `...` wildcards |

4. **Iteratively generalize.** Change ONE element at a time. Run pattern, review matches, classify TP/FP. Stop when FP rate exceeds ~50%.

5. **Analyze and triage.** For each match: location, confidence (High/Med/Low), exploitability, priority.

### Abstraction Ladder

| Level | Pattern | Matches | False Positives | Use Case |
|-------|---------|---------|-----------------|----------|
| 0: Exact Match | Literal vulnerable code | 1 | 0 | Verify specific fix |
| 1: Variable Abstraction | Replace variable names with wildcards | 3-5 | Low | Find copy-paste variants |
| 2: Structural Abstraction | Generalize structure | 10-30 | Medium | Audit a component |
| 3: Semantic Abstraction | Taint mode (any source to any sink) | 50-100+ | High | Full security assessment |

### Critical Pitfalls
- **Narrow scope:** Always search the ENTIRE codebase, not just the module with the original bug.
- **Too-specific pattern:** Enumerate ALL semantically related attributes/functions.
- **Single vulnerability class:** List all possible manifestations before searching.
- **Missing edge cases:** Test with null, undefined, empty collections, boundary conditions.

### FP Management

| Context | Acceptable FP Rate |
|---------|-------------------|
| Automated CI blocking | <5% |
| Developer warning | <20% |
| Security audit triage | <50% |
| Research/exploration | <80% |

---

## CodeQL Setup

### Supported Languages
Python, JavaScript/TypeScript, Go, Java/Kotlin, C/C++, C#, Ruby, Swift.

### Essential Principles

1. **Database quality is non-negotiable.** Always run quality assessment and compare against expected source files.
2. **Data extensions catch what CodeQL misses.** Even projects using standard frameworks have custom wrappers.
3. **Explicit suite references prevent silent query dropping.** Never pass pack names directly -- always generate a custom `.qls` suite file.
4. **Zero findings needs investigation, not celebration.** Can indicate poor database quality, missing models, wrong query packs.

### Output Directory Structure

```
$OUTPUT_DIR/
├── rulesets.txt
├── codeql.db/
├── build.log
├── diagnostics/
├── extensions/
├── raw/
│   ├── results.sarif
│   └── <mode>.qls
└── results/
    └── results.sarif
```

### Database Quality Assessment

```bash
codeql database print-baseline -- "$DB_NAME"
unzip -Z1 "$DB_NAME/src.zip" 2>/dev/null | wc -l
find "$DB_NAME/diagnostic/extractors" -name '*.jsonl' -exec cat {} + 2>/dev/null | grep -c '^{'
grep '^finalised:' "$DB_NAME/codeql-database.yml"
```

| Metric | Good | Poor |
|--------|------|------|
| Baseline LoC | > 0, proportional to project | 0 or far below expected |
| Project source files | Close to expected | < 50% of expected |
| Extractor errors | 0 or < 5% of files | > 5% of files |
| Finalized | `true` | `false` |

### Suite Hierarchy

| Suite | False Positives | Use Case |
|-------|-----------------|----------|
| `security-extended` | Low | Default -- security audits |
| `security-and-quality` | Medium | Comprehensive review |
| `security-experimental` | Higher | Research, vulnerability hunting |

### Query Packs

**Official:** `security-extended`, `security-and-quality`, `security-experimental`
**Trail of Bits:** `codeql pack download trailofbits/{cpp,go,java}-queries`
**Community:** `codeql pack download GitHubSecurityLab/CodeQL-Community-Packs-<Lang>`

### Analysis Command

```bash
codeql database analyze $DB_NAME \
  --format=sarif-latest \
  --output="$RAW_DIR/results.sarif" \
  --threads=0 \
  $THREAT_MODEL_FLAG \
  $MODEL_PACK_FLAGS \
  -- "$SUITE_FILE"
```

---

## Semgrep Scanning

### Modes

**Run all:** All rulesets, no filtering.
**Important only:** Pre-filter by severity + post-filter by metadata (category=security, confidence/MEDIUM+, impact/MEDIUM+).

### Post-Filter jq Command

```bash
jq '{
  results: [.results[] |
    ((.extra.metadata.category // "security") | ascii_downcase) as $cat |
    ((.extra.metadata.confidence // "HIGH") | ascii_upcase) as $conf |
    ((.extra.metadata.impact // "HIGH") | ascii_upcase) as $imp |
    select(
      ($cat == "security") and
      ($conf == "MEDIUM" or $conf == "HIGH") and
      ($imp == "MEDIUM" or $imp == "HIGH")
    )
  ],
  errors: .errors,
  paths: .paths
}' "$f" > "${f%.json}-important.json"
```

### Rulesets

**Always include:** `p/security-audit`, `p/secrets`

| Language | Primary | Frameworks |
|----------|---------|------------|
| Python | `p/python` | `p/django`, `p/flask`, `p/fastapi` |
| JavaScript | `p/javascript` | `p/react`, `p/nodejs`, `p/express`, `p/nextjs` |
| TypeScript | `p/typescript` | `p/react`, `p/nodejs`, `p/express`, `p/nextjs` |
| Go | `p/golang` | -- |
| Java | `p/java` | `p/spring`, `p/findsecbugs` |
| C/C++ | `p/c` | -- |
| Rust | `p/rust` | -- |
| PHP | `p/php` | `p/symfony`, `p/laravel` |
| Ruby | `p/ruby` | `p/rails` |

**Infrastructure:** `p/dockerfile`, `p/terraform`, `p/kubernetes`, `p/cloudformation`, `p/github-actions`
**Third-party:** Trail of Bits, 0xdea (C/C++), Decurity (Solidity/Cairo/Rust)

**Key:** Always use `--metrics=off` -- Semgrep sends telemetry by default.

---

## SARIF Processing

### Common jq Queries

```bash
jq '[.runs[].results[]] | length' results.sarif                    # Total findings
jq 'reduce .runs[].results[] as $r ({}; .[$r.level] += 1)' results.sarif  # Count by severity
jq '[.runs[].results[].ruleId] | unique | sort' results.sarif       # Unique rule IDs
jq '[.runs[].results[]] | group_by(.ruleId) | map({rule: .[0].ruleId, count: length}) | sort_by(-.count)' results.sarif  # Count per rule
jq '.runs[].results[] | {rule: .ruleId, file: .locations[0].physicalLocation.artifactLocation.uri, line: .locations[0].physicalLocation.region.startLine}' results.sarif  # File/line per result
jq -r '.runs[].results[] | [.ruleId, .level, .locations[0].physicalLocation.artifactLocation.uri, .locations[0].physicalLocation.region.startLine, .message.text] | @csv' results.sarif  # CSV output
jq -s '{version: "2.1.0", runs: [.[].runs[]]}' file1.sarif file2.sarif > merged.sarif  # Merge SARIF files
```

### Deduplication

```python
def deduplicate_results(sarif: dict) -> dict:
    seen_fingerprints = set()
    for run in sarif["runs"]:
        unique_results = []
        for result in run.get("results", []):
            fp = None
            if result.get("partialFingerprints"):
                fp = tuple(sorted(result["partialFingerprints"].items()))
            elif result.get("fingerprints"):
                fp = tuple(sorted(result["fingerprints"].items()))
            else:
                loc = result.get("locations", [{}])[0]
                phys = loc.get("physicalLocation", {})
                fp = (
                    result.get("ruleId"),
                    phys.get("artifactLocation", {}).get("uri"),
                    phys.get("region", {}).get("startLine")
                )
            if fp not in seen_fingerprints:
                seen_fingerprints.add(fp)
                unique_results.append(result)
        run["results"] = unique_results
    return sarif
```

### Path Normalization

```python
from urllib.parse import unquote
from pathlib import Path

def normalize_path(uri: str, base_path: str = "") -> str:
    if uri.startswith("file://"):
        uri = uri[7:]
    uri = unquote(uri)
    if not Path(uri).is_absolute() and base_path:
        uri = str(Path(base_path) / uri)
    return str(Path(uri))
```

### Tool Selection

| Use Case | Tool | Installation |
|----------|------|--------------|
| Quick CLI queries | jq | `apt install jq` |
| Python scripting (simple) | pysarif | `pip install pysarif` |
| Python scripting (advanced) | sarif-tools | `pip install sarif-tools` |
| Large files (100MB+) | ijson streaming | `pip install ijson` |
| Validation | jsonschema | `pip install jsonschema` |

### Key Principles

1. Validate first -- check SARIF structure before processing
2. Handle optionals -- many fields are optional; use defensive access
3. Normalize paths -- tools report paths differently; normalize early
4. Fingerprint wisely -- combine multiple strategies for stable deduplication
5. Stream large files -- use ijson for 100MB+ files
