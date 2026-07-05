# Static Analysis Reference

## CodeQL Setup

### Supported Languages
Python, JavaScript/TypeScript, Go, Java/Kotlin, C/C++, C#, Ruby, Swift.

### Essential Principles

1. **Database quality is non-negotiable.** A database that builds is not automatically good. Always run quality assessment (file counts, baseline LoC, extractor errors) and compare against expected source files.
2. **Data extensions catch what CodeQL misses.** Even projects using standard frameworks have custom wrappers around database calls, request parsing, or shell execution. Skipping extensions means missing vulnerabilities in project-specific code paths.
3. **Explicit suite references prevent silent query dropping.** Never pass pack names directly to `codeql database analyze` — each pack's `defaultSuiteFile` applies hidden filters. Always generate a custom `.qls` suite file.
4. **Zero findings needs investigation, not celebration.** Zero results can indicate poor database quality, missing models, wrong query packs, or silent suite filtering.

### Output Directory Structure

```
$OUTPUT_DIR/
├── rulesets.txt                 # Selected query packs
├── codeql.db/                   # CodeQL database
├── build.log                    # Build log
├── diagnostics/                 # Diagnostic queries and CSVs
├── extensions/                  # Data extension YAMLs
├── raw/                         # Unfiltered analysis output
│   ├── results.sarif
│   └── <mode>.qls
└── results/                     # Final results
    └── results.sarif
```

### Database Quality Assessment

```bash
# Baseline lines of code
codeql database print-baseline -- "$DB_NAME"

# Source archive file count
unzip -Z1 "$DB_NAME/src.zip" 2>/dev/null | wc -l

# Extraction errors
find "$DB_NAME/diagnostic/extractors" -name '*.jsonl' \
  -exec cat {} + 2>/dev/null | grep -c '^{'

# Check database is finalized
grep '^finalised:' "$DB_NAME/codeql-database.yml"
```

**Quality criteria:**

| Metric | Good | Poor |
|--------|------|------|
| Baseline LoC | > 0, proportional to project | 0 or far below expected |
| Project source files | Close to expected | < 50% of expected |
| Extractor errors | 0 or < 5% of files | > 5% of files |
| Finalized | `true` | `false` (incomplete build) |

### Quality Improvement Steps

1. Adjust source root
2. Fix "no source code seen" (cached build — force clean rebuild)
3. Install type stubs / additional dependencies
4. Adjust extractor options (C++ TRAP headers, Java JDK version)

## CodeQL Quality

### Suite Hierarchy

| Suite | False Positives | Use Case |
|-------|-----------------|----------|
| `security-extended` | Low | Default — security audits |
| `security-and-quality` | Medium | Comprehensive review |
| `security-experimental` | Higher | Research, vulnerability hunting |

> `security-and-quality` and `security-experimental` are complementary. For maximum coverage (run-all mode), import both.

**Usage:** `codeql/<lang>-queries:codeql-suites/<lang>-security-extended.qls`

### Query Packs

**Official suites:**
- `security-extended` — Low FP, default for security audits
- `security-and-quality` — Excludes `experimental/` query paths
- `security-experimental` — Includes experimental, excludes code quality

**Trail of Bits packs:**
```bash
codeql pack download trailofbits/cpp-queries
codeql pack download trailofbits/go-queries
codeql pack download trailofbits/java-queries
```

**Community packs:**
```bash
codeql pack download GitHubSecurityLab/CodeQL-Community-Packs-<Lang>
```

### Scan Modes

| Mode | Description | Suite Reference |
|------|-------------|-----------------|
| **Run all** | All queries from all installed packs via `security-and-quality` + `security-experimental` | Custom `.qls` |
| **Important only** | Security queries filtered by precision and security-severity threshold | Custom `.qls` with post-filter |

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

**Flags:**
- `--model-packs` — for installed model packs
- `--additional-packs` — for in-repo model packs or standalone extensions
- `--threat-model` — `local`, `remote`, or `all`

## Semgrep Scanning Modes

### Mode: Run All

Full scan with all rulesets and severity levels. No filtering applied.

### Mode: Important Only

Two filter layers:
1. **Pre-filter**: `--severity MEDIUM --severity HIGH --severity CRITICAL`
2. **Post-filter**: JSON metadata — keeps only `category=security`, `confidence∈{MEDIUM,HIGH}`, `impact∈{MEDIUM,HIGH}`

**Post-filter jq command:**
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

Third-party rules without metadata pass all filters by default.

### Semgrep Rulesets

**Always include:**
- `p/security-audit` — Comprehensive vulnerability detection
- `p/secrets` — Hardcoded credentials, API keys

**Language-specific (add primary + framework rulesets):**

| Language | Primary | Frameworks |
|----------|---------|------------|
| Python | `p/python` | `p/django`, `p/flask`, `p/fastapi` |
| JavaScript | `p/javascript` | `p/react`, `p/nodejs`, `p/express`, `p/nextjs` |
| TypeScript | `p/typescript` | `p/react`, `p/nodejs`, `p/express`, `p/nextjs` |
| Go | `p/golang` | — |
| Java | `p/java` | `p/spring`, `p/findsecbugs` |
| C/C++ | `p/c` | — |
| Rust | `p/rust` | — |
| PHP | `p/php` | `p/symfony`, `p/laravel` |
| Ruby | `p/ruby` | `p/rails` |

**Infrastructure:**
- `p/dockerfile`, `p/terraform`, `p/kubernetes`, `p/cloudformation`, `p/github-actions`

**Third-party (required, not optional):**
- Trail of Bits (Python, Go, Ruby, JS/TS, Terraform)
- 0xdea (C, C++)
- Decurity (Solidity, Cairo, Rust)

### Key Semgrep Principle

Always use `--metrics=off` — Semgrep sends telemetry by default. Every `semgrep` command must include this flag.

## SARIF Processing

### SARIF 2.1.0 Structure

```
sarifLog
├── version: "2.1.0"
└── runs[]
    ├── tool
    │   ├── driver
    │   │   ├── name
    │   │   └── rules[]
    │   └── extensions[]
    ├── results[]
    │   ├── ruleId
    │   ├── level (error/warning/note)
    │   ├── message.text
    │   ├── locations[].physicalLocation
    │   ├── fingerprints{}
    │   └── partialFingerprints{}
    └── artifacts[]
```

### Common jq Queries

```bash
# Total findings
jq '[.runs[].results[]] | length' results.sarif

# Count by severity
jq 'reduce .runs[].results[] as $r ({}; .[$r.level] += 1)' results.sarif

# List unique rule IDs
jq '[.runs[].results[].ruleId] | unique | sort' results.sarif

# Count per rule
jq '[.runs[].results[]] | group_by(.ruleId) | map({rule: .[0].ruleId, count: length}) | sort_by(-.count)' results.sarif

# File and line for each result
jq '.runs[].results[] | {
  rule: .ruleId,
  file: .locations[0].physicalLocation.artifactLocation.uri,
  line: .locations[0].physicalLocation.region.startLine
}' results.sarif

# Unique affected files
jq '[.runs[].results[].locations[].physicalLocation.artifactLocation.uri] | unique | sort' results.sarif

# Top 10 most frequent rules
jq '[.runs[].results[]] | group_by(.ruleId) | map({rule: .[0].ruleId, count: length}) | sort_by(-.count) | .[0:10]' results.sarif

# Files with most issues
jq '[.runs[].results[] | .locations[0].physicalLocation.artifactLocation.uri] | group_by(.) | map({file: .[0], count: length}) | sort_by(-.count) | .[0:10]' results.sarif

# Filter by specific rule
jq --arg rule "SQL_INJECTION" '.runs[].results[] | select(.ruleId == $rule)' results.sarif

# Filter by file path
jq --arg file "auth" '.runs[].results[] | select(.locations[].physicalLocation.artifactLocation.uri | contains($file))' results.sarif

# CSV output
jq -r '.runs[].results[] | [.ruleId, .level, .locations[0].physicalLocation.artifactLocation.uri, .locations[0].physicalLocation.region.startLine, .message.text] | @csv' results.sarif

# Merge multiple SARIF files
jq -s '{version: "2.1.0", runs: [.[].runs[]]}' file1.sarif file2.sarif > merged.sarif

# Extract errors only
jq '.runs[].results = [.runs[].results[] | select(.level == "error")]' results.sarif > errors-only.sarif
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

1. **Validate first** — Check SARIF structure before processing
2. **Handle optionals** — Many fields are optional; use defensive access
3. **Normalize paths** — Tools report paths differently; normalize early
4. **Fingerprint wisely** — Combine multiple strategies for stable deduplication
5. **Stream large files** — Use ijson for 100MB+ files
